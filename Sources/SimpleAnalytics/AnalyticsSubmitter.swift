//
//  AnalyticsSubmitter.swift
//  App Analytics
//
//  Created by Dennis Birch on 3/20/21.
//

import Foundation
import os.log

protocol AnalyticsSubmitting {
    func submitItems(_ items: [AnalyticsItem], itemCounts: [String : Int],
                     successHandler: @escaping(String) -> Void,
                     errorHandler: @escaping([AnalyticsItem], [String : Int]) -> Void)
}

struct AnalyticsSubmitter: AnalyticsSubmitting {
    let endpoint: String
    let deviceID: String
    let applicationName: String
    let platform: String
    
    func submitItems(_ items: [AnalyticsItem], itemCounts: [String : Int],
                     successHandler: @escaping(String) -> Void,
                     errorHandler: @escaping([AnalyticsItem], [String : Int]) -> Void) {
        guard endpoint.isEmpty == false else {
            let requiresEnpointString =
                """
                
                ===================
                You must configure the AppAnalytics endpoint property to enable submitting results.
                Use the AppAnalytics.setEndpoint(_:) method before any other use of the SimpleAnalytics framework.
                ===================
                
                """
            os_log("%@", requiresEnpointString)
            errorHandler(items, itemCounts)
            return
        }
        
        guard let url = URL(string: endpoint) else {
            os_log("Can't form URL from endpoint string")
            errorHandler(items, itemCounts)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let requestItem = AnalyticsSubmission(deviceID: deviceID, appName: applicationName, platform: platform, items: items, counters: itemCounts)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(requestItem)
            urlRequest.httpBody = data
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 120
            let task = URLSession(configuration: config).dataTask(with: urlRequest) { (data, response, error) in
                if let taskError = error {
                    os_log("Error posting analytics request: %@", taskError.localizedDescription)
                    errorHandler(items, itemCounts)
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let code = httpResponse.statusCode
                        if (200...299).contains(code) == false {
                            // response code not in accepted range
                            errorHandler(items, itemCounts)
                            return
                        }
                    }

                    if let data = data {
                        let message = handleResponseData(data)
                        successHandler(message)
                    } else {
                        errorHandler(items, itemCounts)
                    }
                }
            }
            task.resume()
        } catch {
            errorHandler(items, itemCounts)
        }

    }
    
    
    private func handleResponseData(_ data: Data) -> String {
        // TODO: Remove!!!
        print("Response data:\n\(String(describing: String(data: data, encoding: .utf8)))")
            // **************
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(AnalyticsSubmissionResponse.self, from: data)
            
            // TODO: Remove!!!
            let info =
                """
                Response deviceID: \(response.deviceID)
                Response appName: \(response.appName)
                Response platform: \(response.platform)
                Response items: \(response.items)
                Response counters: \(response.counters)
                """
            print(info)
            // ***********
            
            return response.message
        } catch {
            os_log("Error decoding response JSON: %@", error.localizedDescription)
            return ""
        }
    }

}

struct AnalyticsSubmission: Encodable {
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case appName = "app_name"
        case platform
        case items
        case counters
    }
    
    let deviceID: String
    let appName: String
    let platform: String
    let items: [AnalyticsItem]
    let counters: [String : Int]
}

struct AnalyticsSubmissionResponse: Decodable {
    let message: String

    // FOR DEBUGGING:
    // TODO: Remove
    let items: [AnalyticsItem]
    let counters: [String : Int]
    let deviceID: String
    let appName: String
    let platform: String
}
