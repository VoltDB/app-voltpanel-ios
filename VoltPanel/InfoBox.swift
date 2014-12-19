//
//  UIMessageText.swift
//  VoltPanel
//
//  Created by Steve Cooper on 12/18/14.
//  Copyright (c) 2014 Steve Cooper. All rights reserved.
//

import UIKit

class InfoBox {

    let uiField: UILabel

    init(_ uiField: UILabel) {
        self.uiField = uiField
    }

    func info(text: String) {
        self.uiField.text = text
        println("INFO: \(text)")
    }

    func error(text: String) {
        self.uiField.text = "* \(text) *"
        println("ERROR: \(text)")
    }
}
