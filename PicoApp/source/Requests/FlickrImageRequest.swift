import Foundation

// NOTE: I understand, this type of API request is a little bit
// overkill for such a small or even for medium size project.
// But my point was to show as much best practices as possible.
// Also with protocol based requests architecture there is no more need
// to use 3rd party libraries as Alomofire or smth. else

/// Protocol based API request with unnecessary for URLRequest parameters
/// Could be easily extend further with additional parameters
public final class FlickrImageRequest: RequestProtocol {
    public var httpMethod: APIHTTPMethod
    private let page: Int
    private let searchTerm: String?
    
    public var url: String? {
        var components = URLComponents()
        components.scheme = Constants.API.scheme
        components.host = Constants.API.host
        components.path = Constants.API.path
        
        var queryItems = [URLQueryItem]()
        if let text = searchTerm {
            queryItems.append(URLQueryItem(name: "text", value: text))
        } else {
            queryItems.append(URLQueryItem(name: "text", value: Constants.API.defaultSearchTerm))
        }
        queryItems.append(URLQueryItem(name: "method", value: Constants.API.flickrSearchMethod))
        queryItems.append(URLQueryItem(name: "format", value: Constants.API.flickrFormat))
        queryItems.append(URLQueryItem(name: "nojsoncallback", value: Constants.API.flickrCallback))
        queryItems.append(URLQueryItem(name: "api_key", value: Constants.API.flickrApiKey))
        queryItems.append(URLQueryItem(name: "per_page", value: Constants.API.perPage))
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        components.queryItems = queryItems
        
        return components.url?.absoluteString
    }

    init(searchTerm text: String? = nil, page: Int = 1, httpMethod: APIHTTPMethod = .get) {
        self.page = page
        self.searchTerm = text
        self.httpMethod = httpMethod
    }

    public func response(_ body: Data, statusCode: APIHttpStatusCode) throws -> ResponseBody {
        return try JSONDecoder().decode(ResponseBody.self, from: body)
    }
}

public struct ResponseBody: Codable, Equatable {
    public let photos: Photos
    public let stat: String
    
    private enum CodingKeys: String, CodingKey {
        case photos, stat
    }
    
    public init(photos: Photos, stat: String) {
        self.photos = photos
        self.stat = stat
    }
}

public struct Photos: Codable, Equatable {
    public let photoItems: [PhotoItem]
    public let page: Int
    public let pagesCount: Int
    public let perPage: Int
    public let total: Int
    
    private enum CodingKeys: String, CodingKey {
        case page, total
        case photoItems = "photo"
        case pagesCount = "pages"
        case perPage = "perpage"
    }

    public init(photoItems: [PhotoItem], page: Int, pagesCount: Int, perPage: Int, total: Int) {
        self.photoItems = photoItems
        self.page = page
        self.pagesCount = pagesCount
        self.perPage = perPage
        self.total = total
    }
}

public struct PhotoItem: Codable, Equatable {
    public let id: String
    public let owner: String
    public let secret: String
    public let server: String
    public let farm: Int
    public let title: String
    public let isPublic: Int
    public let isFriend: Int
    public let isFamily: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }

    public init(
        id: String,
        owner: String,
        secret: String,
        server: String,
        farm: Int,
        title: String,
        isPublic: Int,
        isFriend: Int,
        isFamily: Int
    ) {
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.isPublic = isPublic
        self.isFriend = isFriend
        self.isFamily = isFamily
    }
}
