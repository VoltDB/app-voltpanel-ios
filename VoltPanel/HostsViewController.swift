/* This file is part of VoltDB.
* Copyright (C) 2008-2015 VoltDB Inc.
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

