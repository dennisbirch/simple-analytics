//
//  AnalyticsManager.swift
//
//  Created by Dennis Birch on 3/22/21.
//

import Foundation
import SimpleAnalytics

/*
 This is an app-level manager for SimpleAnalytics to allow avoid calls directly to SimpleAnalytics throughout the rest of the app. If we needed to change to a different Analytics solution, we would then only need to rewrite this file after installing the other analytics solution's dependencies.
 
 Only a few methods required for this demo are included here.
 */

struct DemoAnalytics {
    static func initializeEndpoint() {
        AppAnalytics.setEndpoint("URL FOR YOUR WEB SERVICE")
    }
    
    static func addAnalyticsItem(_ item: String, params: [String : String]? = nil) {
        AppAnalytics.addItem(item, params: params)
        print("Total analytics items: \(AppAnalytics.itemCount)")
    }
    
    static func countItem(_ description: String) {
        AppAnalytics.countItem(description)
        print("Total analytics items: \(AppAnalytics.itemCount)")
    }
}
