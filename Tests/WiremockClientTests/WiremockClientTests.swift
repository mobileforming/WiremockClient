import XCTest
@testable import WiremockClient

class WiremockClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WiremockClient.baseURL, "http://localhost:8080")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
