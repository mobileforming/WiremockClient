//
//  WiremockClientErrorTests.swift
//  WiremockClientTests
//
//  Created by Ted Rothrock on 2/15/21.
//

import XCTest
@testable import WiremockClient

class WiremockClientErrorTests: XCTestCase {

    func test_equatable() throws {
        XCTAssertEqual(WiremockClientError.decodingError, WiremockClientError.decodingError)
        XCTAssertEqual(WiremockClientError.invalidUrl, WiremockClientError.invalidUrl)
        XCTAssertEqual(WiremockClientError.verificationError(description: "desc"), WiremockClientError.verificationError(description: "desc"))
        XCTAssertEqual(WiremockClientError.networkError, WiremockClientError.networkError)
        XCTAssertNotEqual(WiremockClientError.decodingError, WiremockClientError.invalidUrl)
    }

}
