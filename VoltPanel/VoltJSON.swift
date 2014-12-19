//
//  VoltRestInterface.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/15/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import Foundation

// http://docs.voltdb.com/UsingVoltDB/ProgLangJson.php

// Access to index-able items in a generic container.
// Container subclass must override subscript method.
class VoltJSONContainerWrapperBase {
    
    func integer(key: AnyObject) -> Int? {
        return  self[key] as? Int
    }
    
    // Integer value extracted from string type
    func integerFromString(key: AnyObject) -> Int? {
        if let s = self[key] as? String {
            if let i = s.toInt() {
                return i
            }
        }
        return nil
    }
    
    func string(key: AnyObject) -> String? {
        return self[key] as? String
    }
    
    // String that can use "<null>" for null values.
    func stringWithNull(key: AnyObject) -> String? {
        if let s = self[key] as? String {
            if s != "<null>" {
                return s
            }
        }
        return nil
    }
    
    func dictionary(key: AnyObject) -> VoltJSONDictionaryWrapper? {
        if let d = self[key] as? NSDictionary {
            let wrapper = VoltJSONDictionaryWrapper(d)
            return wrapper
        }
        return nil
    }
    
    func tuple(key: AnyObject) -> VoltJSONTupleWrapper? {
        if let t = self[key] as? [AnyObject] {
            return VoltJSONTupleWrapper(t)
        }
        return nil
    }
    
    // Required override.
    subscript(key: AnyObject) -> AnyObject? {
        return nil
    }

    // Required override.
    var count: Int {
        get {
            return 0
        }
    }
}

class VoltJSONTupleWrapper : VoltJSONContainerWrapperBase {
    let tuple: [AnyObject]
    
    init(_ tuple: [AnyObject]) {
        self.tuple = tuple
    }
    
    // Required by VoltJSONContainerWrapperBase
    override subscript(key: AnyObject) -> AnyObject? {
        if let index = key as? Int {
            if index >= 0 && index < self.tuple.count {
                return self.tuple[index]
            }
        } else {
            println("Bad tuple index: \(key)")
        }
        return nil
    }

    // Required VoltJSONContainerWrapperBase override.
    override var count: Int {
        get {
            return self.tuple.count
        }
    }
}

class VoltJSONDictionaryWrapper : VoltJSONContainerWrapperBase {
    let dict: NSDictionary
    
    init(_ dict: NSDictionary) {
        self.dict = dict
    }
    
    // Required by VoltJSONContainerWrapperBase
    override subscript(key: AnyObject) -> AnyObject? {
        if let keyString = key as? String {
            return self.dict[keyString]
        } else {
            println("Bad dictionary key: \(key)")
        }
        return nil
    }

    // Required VoltJSONContainerWrapperBase override.
    override var count: Int {
        get {
            return self.dict.count
        }
    }
}

class VoltJSONSchema : VoltJSONDictionaryWrapper {

    var name: String? {
        get {
            return self.string("name")
        }
    }

    var type: Int? {
        get {
            return self.integer("type")
        }
    }
}

struct VoltJSONTable {
    let data: [VoltJSONTupleWrapper]
    let schema: [VoltJSONSchema]
}

class VoltJSONResult : VoltJSONDictionaryWrapper {

    var status: Int? {
        get {
            return self.integer("status")
        }
    }

    var table: VoltJSONTable? {
        if let data = self.data {
            if let schema = self.schema {
                return VoltJSONTable(data: data, schema: schema)
            }
        }
        return nil
    }

    var data: [VoltJSONTupleWrapper]? {
        if let dataTupleOfTuples = self.tuple("data") {
            //TODO: Pre-allocate or do something smarter?
            var dataTupleArray: [VoltJSONTupleWrapper] = []
            for i in 0..<dataTupleOfTuples.count {
                if let dataTuple = dataTupleOfTuples.tuple(i) {
                    dataTupleArray.append(dataTuple)
                }
            }
            return dataTupleArray
        }
        return nil
    }

    var schema: [VoltJSONSchema]? {
        get {
            if let resultsTuple = self.tuple("schema") {
                //TODO: Pre-allocate or do something smarter?
                var resultsArray: [VoltJSONSchema] = []
                for i in 0..<resultsTuple.count {
                    if let resultDict = resultsTuple.dictionary(i) {
                        resultsArray.append(VoltJSONSchema(resultDict.dict))
                    }
                }
                return resultsArray
            }
            return nil
        }
    }
}

class VoltJSONResults : VoltJSONDictionaryWrapper {

    var status: Int? {
        get {
            return self.integer("status")
        }
    }

    var statusString: String? {
        get {
            return self.string("statusstring")
        }
    }

    var appStatus: Int? {
        get {
            return self.integer("appstatus")
        }
    }

    var appStatusString: String? {
        get {
            return self.string("appstatusstring")
        }
    }

    var results: [VoltJSONResult]? {
        get {
            if let resultsTuple = self.tuple("results") {
                //TODO: Pre-allocate or do something smarter?
                var resultsArray: [VoltJSONResult] = []
                for i in 0..<resultsTuple.count {
                    if let resultDict = resultsTuple.dictionary(i) {
                        resultsArray.append(VoltJSONResult(resultDict.dict))
                    } else {
                    }
                }
                return resultsArray
            }
            return nil
        }
    }

    var tables: [VoltJSONTable] {
        var tables: [VoltJSONTable] = []
        if let results = self.results {
            for result in results {
                if let table = result.table {
                    tables.append(table)
                }
            }
        }
        return tables
    }

    func table(index: Int) -> VoltJSONTable? {
        let tables = self.tables
        if index >= 0 && index < tables.count {
            return self.tables[index]
        }
        return nil
    }
}

protocol VoltJSONResultsDelegate {
    func connectionDidFinishLoading(results: VoltJSONResults)
    func didFailWithError(error: String)
}

class VoltJSONRequest {
    let url: NSURL
    var data = NSMutableData()
    let resultsDelegate: VoltJSONResultsDelegate
    
    init(url: NSURL, resultsDelegate: VoltJSONResultsDelegate) {
        self.url = url
        self.resultsDelegate = resultsDelegate
    }
    
    func get() {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            var parseError: NSError?
            if let dict = NSJSONSerialization.JSONObjectWithData(
                data, options: NSJSONReadingOptions.MutableContainers, error: &parseError)
                    as? NSDictionary {
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultsDelegate.connectionDidFinishLoading(VoltJSONResults(dict))
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let parseError = parseError {
                        self.resultsDelegate.didFailWithError(parseError.description)
                    } else {
                        self.resultsDelegate.didFailWithError(
                            "Unknown error parsing JSON: \(data.description)")
                    }
                }
            }
        }
        task.resume()
    }
}

func buildURLArrayParam(name: String, anyParams: [AnyObject]) -> String {
    var paramsBlock = ""
    for anyParam in anyParams {
        if paramsBlock.isEmpty {
            paramsBlock += "&\(name)=["
        } else {
            paramsBlock += ","
        }
        if let intParam = anyParam as? Int {
            paramsBlock += "\(intParam)"
        } else if let stringParam = anyParam as? String {
            paramsBlock += "'\(stringParam)'"
        } else {
            paramsBlock += "\(anyParam)"
        }
    }
    if !paramsBlock.isEmpty {
        paramsBlock += "]"
    }
    return paramsBlock
}

func buildExecProcURL(host: String, procName: String, anyParams: [AnyObject]) -> String {
    var paramsBlock = buildURLArrayParam("Parameters", anyParams)
    return "http://\(host)/api/1.0/?Procedure=@\(procName)\(paramsBlock)"
}

class VoltJSON {
    let host: String
    let resultsDelegate: VoltJSONResultsDelegate
    
    init(host: String, resultsDelegate: VoltJSONResultsDelegate) {
        self.host = host
        self.resultsDelegate = resultsDelegate
    }
    
    func execProc(procName: String, params: [AnyObject]) {
        let urlString = buildExecProcURL(host, procName, params)
        if let url = NSURL(string: urlString) {
            println("GET: \(urlString)")
            let request = VoltJSONRequest(url: url, resultsDelegate: self.resultsDelegate)
            request.get()
        } else {
            self.resultsDelegate.didFailWithError("Bad NSURL: \(urlString)")
        }
    }
}
