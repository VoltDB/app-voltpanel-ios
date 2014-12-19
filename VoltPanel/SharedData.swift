//
//  DataManager.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/16/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import Foundation

enum PersistentDataState {
    case NO_DATA, LOADED, IGNORED_BAD, NOT_LOADED
}

enum UserDefaultsKey: String {
    case hosts = "hosts"
}

class Host {
    var properties = [String:String]()
    var name: String {
        get {
            if let hostname = self.properties["HOSTNAME"] {
                return hostname
            }
            return "<unknown>"
        }
    }
}

let userDefaults = NSUserDefaults.standardUserDefaults()

protocol SharedDataDelegate {
    func didReceiveData(data: NSDictionary)
    func didReceiveError(error: String)
}

class ProcedureResults {
    var results: VoltJSONResults?
    var error: String?
    
    init() {
    }
}

class ProcedureExecutor : VoltJSONResultsDelegate {
    let procName: String
    let procResults: ProcedureResults
    let callBack: (Void) -> Void
    
    init(procName: String, procResults: ProcedureResults, callBack: (Void) -> Void) {
        self.procName = procName
        self.procResults = procResults
        self.callBack = callBack
    }
    
    func get(host: String, params: [AnyObject]) {
        let voltJSON = VoltJSON(host: host, resultsDelegate: self)
        voltJSON.execProc(procName, params: params)
    }

    func get(host: String) {
        self.get(host, params: [])
    }

    func connectionDidFinishLoading(results: VoltJSONResults) {
        println("Received results: \(results.dict)")
        self.procResults.results = results
        self.procResults.error = nil
        self.callBack()
    }
    
    func didFailWithError(error: String) {
        self.procResults.results = nil
        self.procResults.error = error
        self.callBack()
    }
}

/**
 * Persistent data
 * Access data through the .data singleton member.
 * Do not access data (hosts, state, etc.) members directly!
 */
class SharedData {
    
    var recentHosts: [String] = []
    var persistentDataState: PersistentDataState = .NOT_LOADED
    var selectedHost: String?
    var deployment = ProcedureResults()
    var hosts = [Host]()

    // The magic singleton property.
    class var data: SharedData {
        struct Static {
            static var instance: SharedData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SharedData()
        }
        
        return Static.instance!
    }
    
    init() {
        if let genericItems: AnyObject = userDefaults.objectForKey(UserDefaultsKey.hosts.rawValue) {
            if let loadedItems = genericItems as? [String] {
                self.recentHosts = loadedItems
                self.persistentDataState = .LOADED
            } else {
                self.persistentDataState = .IGNORED_BAD
            }
        } else {
            self.persistentDataState = .NO_DATA
        }
        if (self.persistentDataState != .LOADED) {
            // Seed the hosts list with localhost.
            self.recentHosts = ["localhost:8080"]
        }
    }
    
    func insertRecentHost(host: String) {
        self.deleteRecentHost(host)
        if let foundAtIndex = find(self.recentHosts, host) {
            self.recentHosts.removeAtIndex(foundAtIndex)
        }
        self.recentHosts.insert(host, atIndex: 0)
        self.save()
    }
    
    func deleteRecentHost(host: String) -> Bool {
        if let foundAtIndex = find(self.recentHosts, host) {
            self.recentHosts.removeAtIndex(foundAtIndex)
            self.save()
            return true
        }
        return false
    }
    
    func selectHost(host: String, callBack: (Void) -> Void) {

        //TODO: This nested code structure is a little weird?

        let deploymentRetriever = ProcedureExecutor(
                procName: "SystemInformation", procResults: self.deployment) {

            if let deploymentResults = self.deployment.results {

                var hostsRaw = ProcedureResults()

                let hostsRetriever = ProcedureExecutor(
                    procName: "SystemInformation", procResults: hostsRaw) {

                    if let hostsRawResults = hostsRaw.results {

                        if let table = hostsRawResults.table(0) {
                            var numHosts = 0
                            for tuple in table.data {
                                if let hostIndex = tuple.integer(0) {
                                    if hostIndex >= 0 && hostIndex + 1 > numHosts {
                                        numHosts = hostIndex + 1
                                    }
                                }
                            }
                            if numHosts > 0 {
                                self.hosts = [Host]()
                                for hostIndex in 0..<numHosts {
                                    self.hosts.append(Host())
                                }
                                for tuple in table.data {
                                    //TODO: Again the nested stuff?
                                    if let hostIndex = tuple.integer(0) {
                                        if let name = tuple.string(1) {
                                            if let value = tuple.string(2) {
                                                self.hosts[hostIndex].properties[name] = value
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        self.insertRecentHost(host)
                    }

                    callBack()
                }

                hostsRetriever.get(host, params: ["OVERVIEW"])
            }
        }

        deploymentRetriever.get(host, params: ["DEPLOYMENT"])
    }

    func save() {
        userDefaults.setObject(self.recentHosts, forKey: UserDefaultsKey.hosts.rawValue)
        userDefaults.synchronize()
    }
}
