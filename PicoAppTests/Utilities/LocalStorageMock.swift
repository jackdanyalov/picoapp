import Foundation
@testable import PicoApp

class LocalStorageMock: LocalStorageProtocol {
    
    private var terms = [String]()
    
    var searchTermsList: [String] {
        terms
    }
    
    func save(searchTerm: String) {
        if !searchTerm.isEmpty, !terms.contains(searchTerm) {
            terms.append(searchTerm)
        }
    }
    
    func remove(searchTerm: String) {
        terms.removeAll { $0 == searchTerm }
    }
    
    func reset() {
        terms.removeAll()
    }
    
    func removeAll() {
        terms.removeAll()
    }
    
}
