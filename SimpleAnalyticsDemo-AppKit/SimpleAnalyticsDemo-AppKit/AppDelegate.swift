//
//  AppDelegate.swift
//  SimpleAnalyticsDemo-AppKit
//
//  Created by Dennis Birch on 4/14/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var application: NSApplication?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // initialize the analytics manager with a callback to the function we run at app termination after successful submission
        DemoAnalytics.initializeEndpoint { [weak self] in
            self?.analyticsSubmitted()
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // set the delegate's application property
        self.application = sender
        // submit stored analytics values
        DemoAnalytics.submit()
        // and tell the delegate to wait until we signal it to terminate
        return .terminateLater
    }

    private func analyticsSubmitted() {
        DispatchQueue.main.async { [weak self] in
            // signal the app to terminate now that analytics submission is complete
            self?.application?.reply(toApplicationShouldTerminate: true)
            // and clean up just to be safe
            self?.application = nil
        }
    }
}

