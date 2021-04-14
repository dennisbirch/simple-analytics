//
//  AppDelegate.swift
//  SimpleAnalyticsDemo-AppKit
//
//  Created by Dennis Birch on 4/14/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DemoAnalytics.initializeEndpoint()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

