import XCTest
@testable import PicoApp

class DataFetcherTest: XCTestCase {

    var api: APIClientMock!
    var sut: DataFetcher!
    
    override func setUpWithError() throws {
        api = APIClientMock()
        sut = DataFetcher(api: api)
    }

    override func tearDownWithError() throws {
        sut = nil
        api = nil
    }

    func testWhenSearchImageByCarTermReturnsSuccess() async throws {
        api.stub(FlickrImageRequest.self, response: .mock())
        let result = await sut.searchImages(for: "car", page: 1)
        XCTAssertNotNil(result.value)
        XCTAssertEqual(result.value?.stat, "ok")
    }
    
    func testWhenSearchImageByCarTermReturnsError() async throws {
        api.stub(FlickrImageRequest.self, error: .undefined)
        let result = await sut.searchImages(for: "car", page: 1)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertEqual(result.error, .undefined)
    }
    
    func testWhenFetchesImagesDataAsyncReturnsSuccess() async throws {
        api.stub("https://www.example.com", response: Data())
        let result = await sut.fetchImagesAsync(by: [PhotoItem.mock()])
        XCTAssertNotNil(result.value)
    }
    
    func testWhenFetchesImagesDataAsyncReturnsError() async throws {
        api.stub("https://www.example.com", error: .undefined)
        let result = await sut.fetchImagesAsync(by: [PhotoItem.mock()])
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertEqual(result.error, .undefined)
    }

}
