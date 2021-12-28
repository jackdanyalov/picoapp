import CocoaLumberjack

public struct Logger {
    public static func setup() {
        DDLog.add(DDOSLogger.sharedInstance)
        
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 1
        DDLog.add(fileLogger)
    }
}

/// Describe the main domain from where a log was printed: api, storage, viewModel and ui
public enum Domains: String {
    case api = "[API]"
    case storage = "[Storage]"
    case viewModel = "[ViewModel]"
    case ui = "[UI]"
}


/// Logger case level: info, error, warning
public enum LogCase {
    case info
    case error
    case warning
}

/// Main logger function
/// - Parameters:
///   - domain: ``Domains`` enum. Describes the domain of a log message
///   - logCase: ``LogCase`` enum. Describes the log level
///   - message: Log message
public func log(_ domain: Domains, _ logCase: LogCase, message: String) {
    switch logCase {
    case .info:
        DDLogInfo("\(domain.rawValue): \(message)", level: .info)
    case .error:
        DDLogError("\(domain.rawValue): \(message)", level: .error)
    case .warning:
        DDLogWarn("\(domain.rawValue): \(message)", level: .warning)
    }
}
