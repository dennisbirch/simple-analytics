//
//  AppAnalytics.swift
//  App Analytics
//
//  Created by Dennis Birch on 3/20/21.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import os.log

public class AppAnalytics {
    // MARK: - Public & Accessible Properties

    /// Getter for the count of all active items to be submitted.
    public static var itemCount: Int {
        return shared.items.count + shared.itemCounts.count
    }
    
    /// Property defining an increment value to be added to the maximum number of items to accumulate before submitting to your service. To prevent spamming your server, this value is automatically added to the *maxItemCount* if a submission fails so that the next item added does not prompt another submission. If desired, you can adjust this value with by calling the `setSubmitFailureIncrement` function.
    var maxCountResetValue = 20
    
    /// The value used to set the maximum number of items to accumulate before submitting items to your service. If the *maxItemCount* has been increased because of submission failures, it is reset to this base value upon the next successful submission. You can adjust this value by calling the `setMaximumItemCount` method
    private var baseItemCount = 100
    
    // MARK: - Private Properties
    
    private(set) var items = [AnalyticsItem]()
    private(set) var itemCounts = [String : Int]()
    
    /// An instance of a type that conforms to the `AnalyticsSubmitting` protocol. This has internal scope to allow testing. An instance of the `AnalyticsSubmitter` struct is used automatically unless this property has been set to something else.
    var submitter: AnalyticsSubmitting?
    
    private var maxItemCount = 0

    private var endpoint: String = ""
    private var appName: String
    private var platform: String
    private var deviceID: String
    private var shouldSubmitAtAppDismiss = true
    
    private static var shared = AppAnalytics()
    private static let persistenceFileName = "PersistedAnalytics"

    
    // MARK: - Public Methods
    
    /// Static method to allow overriding the *endPoint* property
    /// - Parameter urlString: String for the endpoint's URL
    public static func setEndpoint(_ urlString: String) {
        shared.endpoint = urlString
    }
    
    /// Static method to add an item to record
    /// - Parameters:
    ///   - description: String describing the action or user interaction
    ///   - params: An optional String:String dictionary of additional details to record (e.g. certain app state observations) for more refined analysis
    public static func addItem(_ description: String, params: [String : String]? = nil) {
        shared.addAnalyticsItem(description, params: params)
    }
    
    /// Static method to count an occurrence of any event
    /// - Parameter description: String describing the item to be counted. A dictionary of count items is set to 1 or incremented by 1 for the description's entry.
    public static func countItem(_ description: String) {
        shared.addCount(description)
    }
    
    /// A static method to trigger submission of collected analytics
    ///
    /// **NOTE**: The framework automatically submits analytics to the server when sufficient numbers have accumulated. You may want to arbitrarily submit entries at other times with this method.
    public static func submitNow() {
        shared.clearAndSubmitItems()
    }
    
    /// A static method to set the *platform* property
    /// - Parameter platformName: String with a platform name. The framework automatically assigns the values *iOS* and *macOS* for those platforms, but if your app is running in a hybrid environment (e.g. iOS app running on Mac), you can override that assignment with this method.
    public static func setPlatform(_ platformName: String) {
        shared.platform = platformName
    }
    
    /// A static method to change the base count for maximum number of items to accumulate
    /// - Parameter count: Int defining the base maximum number of items to accumulate before attempting to submit them to your server. The default value is 100. This number is incremented by the value of the *maxCountResetValue* property in cases of submissions failing.
    public static func setMaxItemCount(_ count: Int) {
        shared.setMaxCount(count)
    }
    
    /// A static method to change the value of the property added to the maximum count after a submission failure.
    /// - Parameter increment: Int defining the amount to be added to the maximum item count before again attempting to submit entries. This value is used when a submission fails to prevent spamming your server.
    public static func setSubmitFailureIncrement(_ increment: Int) {
        shared.maxCountResetValue = increment
    }
    
    /// A static method to allow overriding the *submitAtDismiss* functionality
    /// - Parameter shouldSubmit: AppAnalytics listens for *appWillResign* and *appWillTerminate* notifications. It responds to those when possible by attempting to submit current entries. If you want to override that behavior, you can call this method with an argument of *false*, or re-enable it with an argument of *true*.
    public static func overrideSubmitAtDismiss(shouldSubmit: Bool) {
        shared.shouldSubmitAtAppDismiss = shouldSubmit
    }
    
    /// A static method to write current contents to disk.
    ///
    /// This method can be called from your app to capture the current analytics values. It should probably only be used when the app is being backgrounded or terminated, and in that case with the *shouldSubmitAtAppDismiss* value set to false to avoid duplicating entries.
    public static func persistContents() {
        let fileMgr = FileManager()
        let url = fileMgr.temporaryDirectory.appendingPathComponent(persistenceFileName)
        if fileMgr.fileExists(atPath: url.path) {
            try? fileMgr.removeItem(at: url)
        }
        let model = PersistenceModel(items: shared.items, counters: shared.itemCounts)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            do {
                try data.write(to: url, options: .atomicWrite)
            } catch {
                os_log("Error writing persistence file to temporary directory: %@", error.localizedDescription)
            }
        } catch {
            os_log("Error encoding persistence model: %@", error.localizedDescription)
        }
    }
    
    /// A static method to restore values persisted with the `persistContents` method
    ///
    /// This method can be called from your app to restore values persisted to disk. It should probably only be called when the app is being activated, and in that case with the *shouldSubmitAtAppDismiss* value set to false to avoid duplicating entries.
    public static func restorePersistenceContents() {
        let fileMgr = FileManager()
        let url = fileMgr.temporaryDirectory.appendingPathComponent(persistenceFileName)
        let path = url.path
        if fileMgr.fileExists(atPath: path) == false { return }
        do {
            let data = try Data(contentsOf: url)
            try? fileMgr.removeItem(at: url)
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(PersistenceModel.self, from: data)
                let items = model.items
                let counters = model.counters
                if items.isEmpty == false {
                    let itemsHash = items.hashValue
                    if itemsHash != shared.items.hashValue {
                        shared.items.insert(contentsOf: items, at: 0)
                    }
                }
                if counters.isEmpty == false {
                    let countersHash = counters.hashValue
                    if countersHash != shared.itemCounts.hashValue {
                        for (key, value) in counters {
                            shared.itemCounts[key] = value
                        }
                    }
                }
            } catch {
                os_log("Error decoding persisted model data: %@", error.localizedDescription)
            }
        } catch {
            os_log("Error reading persisted analytics file: %@", error.localizedDescription)
        }
    }
    
    // MARK: - Internal & Private Methods
    
    init(endpoint: String = "", appName: String = "") {
        self.endpoint = endpoint

        var name = appName
        if appName.isEmpty == true {
            if let info = Bundle.main.infoDictionary {
                if let bundleName = info["CFBundleName"] as? String {
                    name = bundleName
                }
            }
        }
        if name.isEmpty == true {
            name = "App name N/A"
        }
      
        self.appName = name

        let analyticsID = "App Analytics Identifier"
        if let identifier = UserDefaults.standard.string(forKey: analyticsID) {
            self.deviceID = identifier
        } else {
            let identifier = UUID().uuidString
            UserDefaults.standard.set(identifier, forKey: analyticsID)
            self.deviceID = identifier
        }
        
        maxItemCount = baseItemCount
        
        #if os(iOS)
        platform = "iOS"
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDismissNotification(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDismissNotification(_:)), name: UIApplication.willTerminateNotification, object: nil)
        #elseif os(macOS)
        platform = "macOS"
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDismissNotification(_:)), name: NSApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDismissNotification(_:)), name: NSApplication.willTerminateNotification, object: nil)
        #endif
    }
    
    func addAnalyticsItem(_ description: String, params: [String : String]? = nil) {
        let item = AnalyticsItem(timestamp: Date(), description: description, parameters: params)
        items.append(item)
    
        let total = items.count + itemCounts.count
        if total >= maxItemCount {
            // submit and clear items if successful or otherwise restore items
            clearAndSubmitItems()
        }
    }
    
    func addCount(_ description: String) {
        if var count = itemCounts[description] {
            count += 1
            itemCounts[description] = count
        } else {
            itemCounts[description] = 1
        }

        let total = items.count + itemCounts.count
        if total >= maxItemCount {
            // submit and clear items if successful or otherwise restore items
            clearAndSubmitItems()
        }
    }
    
    func setMaxCount(_ count: Int) {
        baseItemCount = count
        maxItemCount = baseItemCount
    }
    
    func clearAndSubmitItems() {
        let submitter = self.submitter ?? AnalyticsSubmitter(endpoint: endpoint, deviceID: deviceID, applicationName: appName, platform: platform)
        self.submitter = submitter

        let items = self.items
        let counters = self.itemCounts
        
        self.items.removeAll()
        self.itemCounts.removeAll()
        
        submitter.submitItems(items, itemCounts: counters, successHandler: { [weak self] message in
            os_log("Success submitting analytics at: %@: %@", Date().description, message)
            if let base = self?.baseItemCount {
                self?.maxItemCount = base
            }
        }) { [weak self] (errorItems, errorCounters) in
            // restore to respective properties
            os_log("Analytics submission failed. Restoring items.")
            self?.items.insert(contentsOf: errorItems, at: 0)
            for (description, count) in errorCounters {
                if var oldCount = self?.itemCounts[description] {
                    oldCount += count
                    self?.itemCounts[description] = oldCount
                } else {
                    self?.itemCounts[description] = count
                }
            }
            
            // add to maxCount so there's a delay before retrying
            if let resetValue = self?.maxCountResetValue {
                self?.maxItemCount += resetValue
            }
        }
    }
    
    @objc private func receivedDismissNotification(_ notification: Notification) {
        if shouldSubmitAtAppDismiss == true {
            clearAndSubmitItems()
        }
    }
}


struct PersistenceModel: Codable {
    let items: [AnalyticsItem]
    let counters: [String : Int]
}
