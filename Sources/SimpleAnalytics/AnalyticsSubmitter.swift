//
//  AnalyticsSubmitter.swift
//  App Analytics
//
//  Created by Dennis Birch on 3/20/21.
//

import Foundation

protocol AnalyticsSubmitting {
    func submitItems(_ items: [AnalyticsItem], itemCounts: [AnalyticsCount],
                     successHandler: @escaping(String) -> Void,
                     errorHandler: @escaping([AnalyticsItem], [AnalyticsCount]) -> Void)
}

struct AnalyticsSubmitter: AnalyticsSubmitting {
    let endpoint: String
    let deviceID: String
    let applicationName: String
    let appVersion: String
    let platform: String
    let systemVersion: String
    
    func submitItems(_ items: [AnalyticsItem], itemCounts: [AnalyticsCount],
                     successHandler: @escaping(String) -> Void,
                     errorHandler: @escaping([AnalyticsItem], [AnalyticsCount]) -> Void) {
        guard endpoint.isEmpty == false else {
            let requiresEndpointString =
                """
                
                ===================
                You must configure the AppAnalytics endpoint property to enable submitting results.
                Use the AppAnalytics.setEndpoint(_:) method before any other use of the SimpleAnalytics framework.
                ===================
                
                """
            SimpleAnalytics.debugLog("%@", requiresEndpointString)
            errorHandler(items, itemCounts)
            return
        }
        
        guard let url = URL(string: endpoint) else {
            SimpleAnalytics.debugLog("Can't form URL from endpoint string")
            errorHandler(items, itemCounts)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let requestItem = AnalyticsSubmission(deviceID: deviceID, appName: applicationName, appVersion: appVersion, systemVersion: systemVersion, platform: platform, items: items, counters: itemCounts)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(requestItem)
            urlRequest.httpBody = data
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 120
            let task = URLSession(configuration: config).dataTask(with: urlRequest) { (data, response, error) in
                if let taskError = error {
                    SimpleAnalytics.debugLog("Error posting analytics request: %@", taskError.localizedDescription)
                    errorHandler(items, itemCounts)
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        let code = httpResponse.statusCode
                        if (200...299).contains(code) == false {
                            // response code not in accepted range
                            #if DEBUG
                            if let data = data {
                                let decoder = JSONDecoder()
                                let response = try? decoder.decode(AnalyticsSubmissionResponse.self, from: data)
                                if let response = response {
                                    SimpleAnalytics.debugLog("%@", response.message)
                                } else {
                                    SimpleAnalytics.debugLog("%@",String(describing: String(data: data, encoding: .utf8)))
                                }
                            }
                            #endif
                            errorHandler(items, itemCounts)
                            return
                        }
                    }

                    if let data = data {
                        let message = self.handleResponseData(data)
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
        #if DEBUG
        SimpleAnalytics.debugLog("Response data:\n%@", String(describing: String(data: data, encoding: .utf8)))
        #endif

        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(AnalyticsSubmissionResponse.self, from: data)
            return response.message
        } catch {
            SimpleAnalytics.debugLog("Error decoding response JSON: %@", error.localizedDescription)
            return ""
        }
    }

}

struct AnalyticsSubmission: Encodable {
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case appName = "app_name"
        case appVersion = "app_version"
        case systemVersion = "system_version"
        case platform
        case items
        case counters
    }
    
    let deviceID: String
    let appName: String
    let appVersion: String
    let systemVersion: String
    let platform: String
    let items: [AnalyticsItem]
    let counters: [AnalyticsCount]
}

struct AnalyticsSubmissionResponse: Decodable {
    let message: String
}
