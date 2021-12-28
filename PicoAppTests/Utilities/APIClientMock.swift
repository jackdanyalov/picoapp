import Foundation
@testable import PicoApp

final class APIClientMock: APIClientProtocol {
    private var stubs = [AnyObject]()
    private var stubsUrl = [AnyObject]()
    
    @discardableResult
    func stub<Request: RequestProtocol>(_ request: Request.Type,
                                        response: Request.Response) -> APIClientRequestStub<Request> {
        stub(request, result: { _ in .success(response) })
    }
    
    @discardableResult
    func stub<Request: RequestProtocol>(_ request: Request.Type,
                                        error: APIError) -> APIClientRequestStub<Request> {
        stub(request, result: { _ in .failure(error) })
    }
    
    @discardableResult
    func stub(_ urlString: String, response: Data) -> APIClientRequestURLStub {
        stubUrl(urlString, result: { _ in .success(response)})
    }
    
    @discardableResult
    func stub(_ urlString: String, error: APIError) -> APIClientRequestURLStub {
        stubUrl(urlString, result: { _ in .failure(error)})
    }
    
    @discardableResult
    private func stub<Request: RequestProtocol>(_ request: Request.Type,
                                        result: @escaping (Request) -> Result<Request.Response, APIError>) -> APIClientRequestStub<Request> {
        let stub = APIClientRequestStub<Request>(send: result)
        addStub(stub)
        return stub
    }
    
    @discardableResult
    private func stubUrl(_ urlString: String,
                 result: @escaping (String) -> Result<Data, APIError>) -> APIClientRequestURLStub {
        let stub = APIClientRequestURLStub(send: result)
        addStubUrl(stub)
        return stub
    }
    
    private func addStub<Request: RequestProtocol>(_ stub: APIClientRequestStub<Request>) {
        stubs.append(stub)
    }
    
    private func addStubUrl(_ stub: APIClientRequestURLStub) {
        stubsUrl.append(stub)
    }
    
    private func getStub<Request: RequestProtocol>(for request: Request) -> APIClientRequestStub<Request> {
        let stub = stubs.reversed()
            .compactMap { $0 as? APIClientRequestStub<Request> }
            .first
        
        precondition(stub != nil, "No stubs registered for request: \(request)")
        return stub!
    }
    
    private func getStubUrl() -> APIClientRequestURLStub {
        let stub = stubsUrl.reversed()
            .compactMap { $0 as? APIClientRequestURLStub }
            .first
        
        precondition(stub != nil, "No stubs registered")
        return stub!
    }
    
    func send<Request: RequestProtocol>(request: Request) async -> Request.RequestResult {
        let stub = getStub(for: request)
        let result = await stub.send(request)
        return result
    }

    func send(urlString: String) async -> Result<Data, APIError> {
        let stub = getStubUrl()
        let result = await stub.send(urlString)
        return result
    }
}

// MARK: - APIClientRequestStub

final class APIClientRequestStub<Request: RequestProtocol> {
    typealias Response = Request.Response
    var send: (Request) async -> Result<Response, APIError>
    
    init(send: @escaping (Request) -> Result<Response, APIError>) {
        self.send = send
    }
}

final class APIClientRequestURLStub {
    var send: (String) async -> Result<Data, APIError>
    
    init(send: @escaping (String) -> Result<Data, APIError>) {
        self.send = send
    }
}
