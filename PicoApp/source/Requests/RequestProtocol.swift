import Foundation

/// Request protocol for building different requests for APIClient
public protocol RequestProtocol: AnyObject {
    typealias RequestResult = Result<Response, APIError>
    associatedtype Response

    var httpMethod: APIHTTPMethod { get }
    var url: String? { get }
    
    /// Function to decode response data to a specified model object
    /// - Parameter body: Data object which need to be decoded
    /// - Parameter statusCode: ``APIHttpStatusCode`` with response status code
    /// - Returns: Decoded response for further using
    func response(_ body: Data, statusCode: APIHttpStatusCode) throws -> Response
}
