import Foundation

protocol MainViewModelProtocol {
    
    /// Parameter with all urls to download images
    var imageUrlStrings: [String] { get }
    
    /// Urls count in ``imageUrlStrings`` for UICollectionView
    var urlsCount: Int { get }
    
    /// Total pages count for a given search term
    var pagesCount: Int { get }
    
    /// Total items count for a given search term
    var totalCount: Int { get }
    
    /// Array of search terms saved as history in local storage
    var searchTerms: [String] { get }
    
    /// Fetches urls for further images downloading
    /// - Parameter searchTerm: Search term
    /// - Parameter page: Page number
    /// - Returns: Optional error
    func fetchRecentImages(searchTerm: String, page: Int) async -> Error?
    
    /// Saves search term in local storage for further using as history
    /// - Parameter searchTerm: Search term which need to be saved
    func save(searchTerm: String)
    
    /// Removes search term from local storage
    /// - Parameter searchTerm: Search term which need to be removed
    func remove(searchTerm: String)
    
    /// Resets ``imageUrlStrings``, ``pagesCount`` and ``totalCount``
    func reset()
}

class MainViewModel: MainViewModelProtocol {
    
    private let dataFetcher: DataFetcherProtocol
    private let localStorage: LocalStorageProtocol
    
    var imageUrlStrings = [String]()
    var pagesCount = 0
    var totalCount = 0
    
    init(dataFetcher: DataFetcherProtocol, localStorage: LocalStorageProtocol) {
        self.dataFetcher = dataFetcher
        self.localStorage = localStorage
    }
    
    var urlsCount: Int {
        imageUrlStrings.count
    }
    
    var searchTerms: [String] {
        localStorage.searchTermsList
    }
    
    public func fetchRecentImages(searchTerm: String, page: Int) async -> Error? {
        let result = await dataFetcher.searchImages(for: searchTerm, page: page)
        switch result {
        case .success(let response):
            pagesCount = response.photos.pagesCount
            totalCount = response.photos.total
            createUrls(response.photos.photoItems)
            return nil
        case .failure(let error):
            return error
        }
    }
    
    func reset() {
        imageUrlStrings.removeAll()
        pagesCount = 0
        totalCount = 0
    }

    /// Prepares urls for images downloade from fetched PhotoItem array
    private func createUrls(_ photos: [PhotoItem]) {
        //"https://farm\(farm).static.flickr.com/\(serverId)/\(imageId)_\(secret).jpg"
        let urlStrings = photos.map { photo -> String in
            "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        }
        imageUrlStrings.append(contentsOf: urlStrings)
    }
    
    func save(searchTerm: String) {
        localStorage.save(searchTerm: searchTerm)
    }

    func remove(searchTerm: String) {
        localStorage.remove(searchTerm: searchTerm)
    }
}
