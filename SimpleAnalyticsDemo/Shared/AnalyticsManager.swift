//
//  AnalyticsManager.swift
//
//  Created by Dennis Birch on 3/22/21.
//

import Foundation
import SimpleAnalytics
#if os(iOS)
import UIKit
#endif

/*
 This is an app-level manager for SimpleAnalytics to allow avoid calls directly to SimpleAnalytics throughout the rest of the app. If we needed to change to a different Analytics solution, we would then only need to rewrite this file after installing the other analytics solution's dependencies.
 
 Only a few methods required for this demo are included here.
 */

// To test this with your own back-end setup, change the following line to reflect the URL string for your analytics server
let webServiceURL = "https://analytics.example.com"

struct DemoAnalytics {
    static func initializeEndpoint(submissionCompletion: (() -> Void)? = nil) {
        #if os(macOS)
        AppAnalytics.setEndpoint(webServiceURL, deviceID: deviceID, submissionCompletionCallback: submissionCompletion)
        #elseif os(iOS)
        AppAnalytics.setEndpoint(webServiceURL, sharedApp: UIApplication.shared)
        #endif
    }
    
    static func addAnalyticsItem(_ item: String, params: [String : String]? = nil) {
        AppAnalytics.addItem(item, params: params)
        print("Total analytics items: \(AppAnalytics.itemCount)")
    }
    
    static func countItem(_ description: String) {
        AppAnalytics.countItem(description)
        print("Total analytics items: \(AppAnalytics.itemCount)")
    }
    
    static func submit() {
        AppAnalytics.submitNow()
    }
    
    private static var deviceID: String {
        // read device ID from a file in the user's app support folder, or create it and persist it for later retrieval
        let fileName = "Device Identifier"
        let fileURL = appSupportFolder.appendingPathComponent(fileName)
        
        let fileMgr = FileManager.default
        if fileMgr.fileExists(atPath: fileURL.path) {
            let uuid = try? String(contentsOf: fileURL, encoding: .utf8)
            if let deviceID = uuid {
                return deviceID
            } else {
                fatalError("Failed to read device ID from file")
            }
        } else {
            let uuid = UUID().uuidString
            try? uuid.write(to: fileURL, atomically: true, encoding: .utf8)
            if fileMgr.fileExists(atPath: fileURL.path) == false { fatalError("Failed to save device ID file") }
            
            return uuid
        }
    }
    
    private static var appSupportFolder: URL {
        let fileMgr = FileManager.default
        guard let folder = fileMgr.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError()
        }
        if fileMgr.fileExists(atPath: folder.path) == false { fatalError("App support folder missing") }
        
        let demoFolderURL = folder.appendingPathComponent("SimpleAnalyticsDemo")
        var isFolder = true as ObjCBool
        if fileMgr.fileExists(atPath: demoFolderURL.path, isDirectory: &isFolder) == false {
            try? fileMgr.createDirectory(at: demoFolderURL, withIntermediateDirectories: true)
        }
        if fileMgr.fileExists(atPath: demoFolderURL.path) == false { fatalError("Failed to create folder") }
        
        return demoFolderURL
    }
}
