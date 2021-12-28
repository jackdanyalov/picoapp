import XCTest
@testable import PicoApp

class MainViewModelTest: XCTestCase {
    
    var sut: MainViewModel!
    var dataFetcher: DataFetcher!
    var api: APIClientMock!
    var localStorage: LocalStorageMock!
    
    override func setUpWithError() throws {
        api = APIClientMock()
        dataFetcher = DataFetcher(api: api)
        localStorage = LocalStorageMock()
        sut = MainViewModel(dataFetcher: dataFetcher, localStorage: localStorage)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        localStorage = nil
        dataFetcher = nil
        api = nil
    }
    
    func testWhenSearchImageByCarTermReturnsSuccess() async throws {
        sut.imageUrlStrings.removeAll()
        api.stub(FlickrImageRequest.self, response: .mock())
        let error = await sut.fetchRecentImages(searchTerm: "car", page: 1)
        XCTAssertNil(error)
        XCTAssertTrue(!sut.imageUrlStrings.isEmpty)
        XCTAssertEqual(sut.imageUrlStrings.count, 1)
        XCTAssertEqual(sut.totalCount, 10)
        XCTAssertEqual(sut.pagesCount, 10)
    }
    
    func testWhenSearchImageByCarTermReturnsError() async throws {
        sut.imageUrlStrings.removeAll()
        api.stub(FlickrImageRequest.self, error: .undefined)
        let error = await sut.fetchRecentImages(searchTerm: "car", page: 1)
        XCTAssertNotNil(error)
        XCTAssertTrue(sut.imageUrlStrings.isEmpty)
        XCTAssertEqual(sut.imageUrlStrings.count, 0)
        XCTAssertEqual(sut.totalCount, 0)
        XCTAssertEqual(sut.pagesCount, 0)
    }
    
    func testResetAllData() async {
        sut.imageUrlStrings.removeAll()
        api.stub(FlickrImageRequest.self, response: .mock())
        let error = await sut.fetchRecentImages(searchTerm: "car", page: 1)
        XCTAssertNil(error)
        XCTAssertEqual(sut.imageUrlStrings.count, 1)
        XCTAssertEqual(sut.totalCount, 10)
        XCTAssertEqual(sut.pagesCount, 10)
        sut.reset()
        XCTAssertEqual(sut.imageUrlStrings.count, 0)
        XCTAssertEqual(sut.totalCount, 0)
        XCTAssertEqual(sut.pagesCount, 0)
    }
    
    func testSaveSearchTermInLocalStorage() {
        localStorage.reset()
        sut.save(searchTerm: "car")
        sut.save(searchTerm: "dog")
        XCTAssertEqual(localStorage.searchTermsList.count, 2)
        XCTAssertEqual(sut.searchTerms.count, 2)
        XCTAssertEqual(localStorage.searchTermsList.first, "car")
    }
    
    func testRemoveSearchTermFromLocalStorage() {
        localStorage.reset()
        sut.save(searchTerm: "car")
        sut.save(searchTerm: "dog")
        XCTAssertEqual(localStorage.searchTermsList.count, 2)
        XCTAssertEqual(localStorage.searchTermsList.first, "car")
        
        sut.remove(searchTerm: "dog")
        XCTAssertEqual(localStorage.searchTermsList.count, 1)
        XCTAssertNotEqual(localStorage.searchTermsList.first, "dog")
    }
    
}
