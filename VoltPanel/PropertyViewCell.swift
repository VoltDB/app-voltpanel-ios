//
//  PropertyViewCell.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/18/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import UIKit

class PropertyCell : UITableViewCell {
    @IBOutlet var uiName: UILabel!
    @IBOutlet var uiValue: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
