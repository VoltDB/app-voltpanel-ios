//
//  ConnectionViewController.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/16/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import UIKit

class ConnectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var uiHostList: UITableView!
    @IBOutlet weak var uiHost: UITextField!
    @IBOutlet weak var uiMessage: UILabel!

    var infoBox: InfoBox!

    let sharedData = SharedData.data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoBox = InfoBox(self.uiMessage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Close keyboard when touch happens outside fields.
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    //=== Connect button
    
    @IBAction func onConnect(sender: AnyObject) {
        let host = self.uiHost.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if host.isEmpty {
            self.infoBox.error("A host is required to connect.")
        } else {
            self.sharedData.selectHost(host) {
                if let results = self.sharedData.deployment.results {
                    if let table = results.table(0) {
                        self.uiHostList.reloadData()
                        self.uiHost.resignFirstResponder()
                        var numHosts = self.sharedData.hosts.count
                        self.infoBox.info("\(host) has \(table.data.count) properties and \(numHosts) host(s).")
                    } else {
                        self.infoBox.error("Results did not have data.")
                    }
                } else {
                    self.infoBox.error(self.sharedData.deployment.error!)
                }
            }
        }
    }
    
    //=== UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sharedData.recentHosts.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Previous Hosts"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let id = "row\(indexPath.row+1)"
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: id)
        cell.textLabel?.text = self.sharedData.recentHosts[indexPath.row]
        return cell
    }
    
    //=== UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = uiHostList.cellForRowAtIndexPath(indexPath) {
            if let textLabel = cell.textLabel {
                self.uiHost.text = textLabel.text
            }
        }
    }
}