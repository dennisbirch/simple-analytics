//
//  ViewController.swift
//  SimpleAnalyticsDemo-AppKit
//
//  Created by Dennis Birch on 4/14/21.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        DemoAnalytics.addAnalyticsItem("Display main view")
    }

    @IBAction func handleButtonPress(_ sender: NSButton) {
        let name = sender.title
        
        if name.lowercased().contains("repeat") {
            DemoAnalytics.countItem(name)
        } else {
            DemoAnalytics.addAnalyticsItem(name)
        }
    }

}

