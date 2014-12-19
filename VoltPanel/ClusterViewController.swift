//
//  ClusterViewController.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/12/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import UIKit

class ClusterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var uiProperties: UITableView!
    @IBOutlet weak var uiMessage: UILabel!

    let sharedData = SharedData.data

    //=== View controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiProperties.registerClass(UITableViewCell.self, forCellReuseIdentifier: "propertyCell")
        
        // Register property cell NIB (resource) to allow use in tableView:cellForRowAtIndexPath
        let cellNib = UINib(nibName: "PropertyCell", bundle: nil)
        self.uiProperties.registerNib(cellNib, forCellReuseIdentifier: "propertyCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //=== Table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = sharedData.deployment.results {
            if let table = results.table(0) {
                return table.data.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.uiProperties.dequeueReusableCellWithIdentifier("propertyCell") as PropertyCell
        var name = "?"
        var value = "?"
        if let results = sharedData.deployment.results {
            if let table = results.table(0) {
                let row = table.data[indexPath.row]
                if let rowName = row.string(0) {
                    name = rowName
                }
                if let rowValue = row.string(1) {
                    value = rowValue
                }
            }
        }
        cell.uiName.text = name
        cell.uiValue.text = value
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Cluster Properties"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
