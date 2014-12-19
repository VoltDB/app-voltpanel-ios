//
//  HostsViewController.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/12/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import UIKit

class HostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        return self.sharedData.hosts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.uiProperties.dequeueReusableCellWithIdentifier("propertyCell") as PropertyCell
        cell.uiName.text = "\(indexPath.row+1)"
        cell.uiValue.text = self.sharedData.hosts[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Hosts"
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}

