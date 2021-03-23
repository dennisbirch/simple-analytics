//
//  SimpleAnalyticsDemoApp.swift
//  Shared
//
//  Created by Dennis Birch on 3/23/21.
//

import SwiftUI

@main
struct SimpleAnalyticsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    DemoAnalytics.initializeEndpoint()
                }
        }
    }
}
