import XCTest
@testable import PicoApp

class LocalStorageTest: XCTestCase {
    
    var sut: LocalStorage!
    var storage: UserDefaults!
    
    override func setUpWithError() throws {
        storage = UserDefaults(suiteName: "LocalStorageTest")
        sut = LocalStorage(userDefauls: storage)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        storage = nil
    }
    
    func testSaveSearchTermInLocalStorage() {
        sut.removeAll()
        sut.save(searchTerm: "car")
        XCTAssertTrue(!sut.searchTermsList.isEmpty)
        XCTAssertEqual(sut.searchTermsList.count, 1)
    }
    
    func testRemoveSearchTermFromLocalStorage() {
        sut.removeAll()
        sut.save(searchTerm: "car")
        sut.save(searchTerm: "dog")
        XCTAssertTrue(!sut.searchTermsList.isEmpty)
        XCTAssertEqual(sut.searchTermsList.count, 2)
        XCTAssertEqual(sut.searchTermsList.first, "car")
        sut.remove(searchTerm: "car")
        XCTAssertEqual(sut.searchTermsList.count, 1)
        XCTAssertEqual(sut.searchTermsList.first, "dog")
    }
    
    func testRemoveAllSearchTermsFromLocalStorage() {
        sut.removeAll()
        sut.save(searchTerm: "car")
        sut.save(searchTerm: "dog")
        XCTAssertTrue(!sut.searchTermsList.isEmpty)
        XCTAssertEqual(sut.searchTermsList.count, 2)
        sut.removeAll()
        XCTAssertTrue(sut.searchTermsList.isEmpty)
    }
}
