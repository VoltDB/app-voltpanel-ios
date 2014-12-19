/* This file is part of VoltDB.
* Copyright (C) 2008-2014 VoltDB Inc.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with VoltDB.  If not, see <http://www.gnu.org/licenses/>.
*/

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