import Foundation

protocol ValueErrorAccessible {
    associatedtype Success
    associatedtype Failure: Swift.Error
    
    var error: Failure? { get }
    var value: Success? { get }
}

extension Result: ValueErrorAccessible {
    var value: Success? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    var error: Failure? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
