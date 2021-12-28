import Foundation

protocol LocalStorageProtocol {
    
    /// Saved search terms in local storage
    var searchTermsList: [String] { get }
    
    /// Saves unique search term to local storage
    /// - Parameter searchTerm: Search term string
    func save(searchTerm: String)
    
    /// Removes search term from local storage
    /// - Parameter searchTerm: Search term string
    func remove(searchTerm: String)
    
    /// Removes all search terms from local storage
    func removeAll()
}

final class LocalStorage: LocalStorageProtocol {
    
    struct Keys {
        static let searchTerms = Constants.Storage.searchTerms
    }
    
    private let userDefaults: UserDefaults
    
    private var searchTerms: [String] {
        get {
            do {
                guard let object: Data = userDefaults.object(forKey: Keys.searchTerms) as? Data else {
                    return []
                }
                return try JSONDecoder().decode([String].self, from: object)
            } catch {
                log(.storage, .error, message: "Error occured while get data from local storage! Error: \(error.localizedDescription)")
                return []
            }
        }
        
        set {
            do {
                let jsonData = try JSONEncoder().encode(newValue)
                userDefaults.set(jsonData, forKey: Keys.searchTerms)
            } catch {
                log(.storage, .error, message: "Error occured while saving data to local storage! Error: \(error.localizedDescription)")
            }
        }
    }

    var searchTermsList: [String] {
        searchTerms
    }
    
    init(userDefauls: UserDefaults = .standard) {
        self.userDefaults = userDefauls
    }
    
    func save(searchTerm: String) {
        if !searchTerms.contains(searchTerm) && !searchTerm.isEmpty {
            searchTerms.append(searchTerm)
        }
    }
    
    func remove(searchTerm: String) {
        searchTerms.removeAll { $0 == searchTerm }
    }
    
    func removeAll() {
        searchTerms.removeAll()
    }
    
}
