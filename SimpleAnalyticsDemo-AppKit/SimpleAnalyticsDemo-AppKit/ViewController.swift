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
            DemoAnalytics.addAnalyticsItem(name, params: ["Demo detail" : randomString()])
        }
    }

    private func randomString() -> String {
        let wordArray = "The quick brown fox jumped over the cow".split(separator: " ")
        let count = wordArray.count
        let index = arc4random_uniform(UInt32(count))
        return String(wordArray[Int(index)])
    }
}

