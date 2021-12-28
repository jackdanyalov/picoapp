import Foundation

protocol APIClientProtocol: AnyObject {
    
    /// Generic based request function for API calls
    /// - Parameter request: Protocol based self-contained request with needed params as HTTP method, url, etc.
    /// Could be extendent in future with another params as header, token, body, etc.
    /// - Returns: Return needed result in generic format which defined in RequestProtocol
    func send<Request: RequestProtocol>(request: Request) async -> Request.RequestResult
    
    /// Simple URL base request for fetching data. Suitable mainly for Images donwloading as well for unserialized
    /// Data.self object
    /// - Parameter urlString: String with correct url definition
    /// - Returns: Result<Data, APIError> - returns Data.self type if success, APIError otherwise
    func send(urlString: String) async -> Result<Data, APIError>
}

class APIClient: NSObject, APIClientProtocol {
    
    lazy private var session: URLSession = {
        let config = APIClient.getUrlSessionConfiguration
        return URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }()
    
    func send<Request>(request: Request) async -> Request.RequestResult where Request : RequestProtocol {
        await sendRequest(request)
    }

    func send(urlString: String) async -> Result<Data, APIError> {
        await sendURLRequest(urlString)
    }
}

private extension APIClient {
    func sendRequest<Request: RequestProtocol>(_ request: Request) async -> Request.RequestResult {
        guard let urlString = request.url, let url = URL(string: urlString) else {
            return .failure(.wrongURL)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        
        do {
            log(.api, .info, message: "Request to \(urlString) was sent!")
            let (data, response) = try await session.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                log(.api, .error, message: "Request was failed! Error: \(APIError.validationFailure)")
                return .failure(.validationFailure)
            }

            let convertedResponse = try request.response(data, statusCode: APIHttpStatusCode(httpResponse.statusCode))
            return .success(convertedResponse)
        } catch {
            log(.api, .error, message: "Request was failed! Error: \(error.localizedDescription)")
            return .failure(.undefined)
        }
    }

    func sendURLRequest(_ urlString: String) async -> Result<Data, APIError> {
        guard let url = URL(string: urlString) else {
            return .failure(.wrongURL)
        }
        do {
            log(.api, .info, message: "Request to \(urlString) was sent!")
            let (data, response) = try await session.data(from: url)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                log(.api, .error, message: "Request was failed! Error: \(APIError.validationFailure)")
                return .failure(.validationFailure)
            }
            return .success(data)
        } catch {
            log(.api, .error, message: "Request was failed! Error: \(error.localizedDescription)")
            return .failure(.undefined)
        }
    }
}

extension APIClient: URLSessionDelegate {
    private static var getUrlSessionConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        let timeout = Constants.API.timeout
        config.timeoutIntervalForRequest = TimeInterval(timeout)
        config.timeoutIntervalForResource = TimeInterval(timeout)
        return config
    }
}
