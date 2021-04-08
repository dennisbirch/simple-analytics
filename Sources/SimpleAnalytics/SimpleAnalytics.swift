import os.log


public struct SimpleAnalytics {
    private static var logger = OSLog(subsystem: "SimpleAnalytics", category: "")
    
    public static func debugLog(_ message: StaticString, _ arg: String? = nil) {
        if let arg = arg {
            os_log(message, log: logger, type: .default, arg)
        } else {
            os_log(message, log: logger, type: .default)
        }
    }
}
