import Foundation
@testable import PicoApp

extension ResponseBody {
    public static func mock() -> ResponseBody {
        let photoItems = [
            PhotoItem.mock()
        ]
        
        let photos = Photos(
            photoItems: photoItems,
            page: 1,
            pagesCount: 10,
            perPage: 10,
            total: 10
        )
        
        return .init(photos: photos, stat: "ok")
    }
}

extension PhotoItem {
    public static func mock() -> PhotoItem {
        PhotoItem(
            id: "23451156376",
            owner: "",
            secret: "8983a8ebc7",
            server: "578",
            farm: 1,
            title: "Mock",
            isPublic: 1,
            isFriend: 0,
            isFamily: 0)
    }
}
