import os.log


struct SimpleAnalytics {
    private static var logger = OSLog(subsystem: "SimpleAnalytics", category: "")
    
    static func debugLog(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: logger, type: .debug, args)
    }
}
