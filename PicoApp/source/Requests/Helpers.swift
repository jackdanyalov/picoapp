import Foundation

/// HTTP Methods for URLRequest
public enum APIHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Possible HTTP status code from response
public enum APIHttpStatusCode: Hashable {
    case undefined(Int)
    case success
    case created
    case badRequest
    case unauthorizedRequest
    case notFound
    case badGateway
    case gatewayTimeout
    
    public init(_ statusCode: Int) {
        switch statusCode {
        case 200:
            self = .success
        case 201:
            self = .created
        case 400:
            self = .badRequest
        case 401:
            self = .unauthorizedRequest
        case 404:
            self = .notFound
        case 502:
            self = .badGateway
        case 504:
            self = .gatewayTimeout
        default:
            self = .undefined(statusCode)
        }
    }
    
    public var rawValue: Int {
        switch self {
        case .success:
            return 200
        case .created:
            return 201
        case .badRequest:
            return 400
        case .unauthorizedRequest:
            return 401
        case .notFound:
            return 404
        case .badGateway:
            return 502
        case .gatewayTimeout:
            return 504
        case let .undefined(value):
            return value
        }
    }
}

/// Predefined possible request & response errors
public enum APIError: Error {
    case backend
    case mappingFailure
    case validationFailure
    case wrongURL
    case requestNotSupported
    case undefined
}
