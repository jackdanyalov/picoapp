import Foundation

enum Constants {
    
    public struct API {
        public static let timeout: Double = 60
        public static let scheme = "https"
        public static let host = "flickr.com"
        public static let path = "/services/rest/"
        public static let flickrApiKey = "fb801032ad9cf224543a47db2acf4907"
        public static let flickrSearchMethod = "flickr.photos.search"
        public static let flickrFormat = "json"
        public static let flickrCallback = "1"
        public static let perPage = "30"
        public static let defaultSearchTerm = "car"
    }
    
    public struct Cell {
        public static let collectionViewCellId = "CollectionViewCellId"
        public static let tableViewCellId = "TableViewCellId"
    }
    
    public struct Storage {
        public static let searchTerms = "searchTerms"
    }
    
}
