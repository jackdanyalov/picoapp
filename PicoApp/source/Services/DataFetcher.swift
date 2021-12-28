import Foundation

protocol DataFetcherProtocol {
    
    /// Searchs images related to a search text
    /// - Parameter text: Search term
    /// - Parameter page: Current loading page
    /// - Returns: Result<ResponseBody, APIError>
    func searchImages(for searchTerm: String, page: Int) async -> Result<ResponseBody, APIError>
    
    /// Fetchs images in parallel way related to prepared urls under the data from ``searchImages(for searchTerm:, page:) async -> Result<ResponseBody, APIError>`` function
    /// - Parameter photos: Array of PhotoItem objects
    /// - Returns: Result<[Data], APIError> - Result of array of Data if success, APIError otherwise
    func fetchImagesAsync(by photos: [PhotoItem]) async -> Result<[Data], APIError>
}

final class DataFetcher: DataFetcherProtocol {
    
    private let api: APIClientProtocol
    
    init(api: APIClientProtocol) {
        self.api = api
    }
    
    public func searchImages(for searchTerm: String, page: Int) async -> Result<ResponseBody, APIError> {
        let request = FlickrImageRequest(searchTerm: searchTerm, page: page)
        return await api.send(request: request)
    }

    /**
     Actually this function is not used in this project. I thought about using this one, but for simplicity
     of images caching and the project decided to go with Kingfisher library.
     Decided to not remove it just to show how easily we can make parallel API calls with async/await solutions
     */
    public func fetchImagesAsync(by photos: [PhotoItem]) async -> Result<[Data], APIError> {
        do {
            return try await withThrowingTaskGroup(of: Data.self) { [weak self] group in
                guard let self = self else {
                    return .failure(.undefined)
                }
                for photo in photos {
                    group.addTask {
                        let result = await self.getImageData(farm: photo.farm, imageId: photo.id, serverId: photo.server, secret: photo.secret)
                        switch result {
                        case .success(let data):
                            return data
                        case .failure(let error):
                            log(.api, .error, message: "Request was failed! Error: \(error)")
                            throw error
                        }
                    }
                }
                
                var datas = [Data]()
                for try await data in group {
                    datas.append(data)
                }
                return .success(datas)
            }
        } catch {
            log(.api, .error, message: "Request was failed! Error: \(APIError.undefined)")
            return .failure(.undefined)
        }
    }

    private func getImageData(farm: Int, imageId: String, serverId: String, secret: String) async -> Result<Data, APIError> {
        // Example: https://farm66.static.flickr.com/65535/51775750127_251b70283f.jpg
        await api.send(urlString: "https://farm\(farm).static.flickr.com/\(serverId)/\(imageId)_\(secret).jpg")
    }
}
