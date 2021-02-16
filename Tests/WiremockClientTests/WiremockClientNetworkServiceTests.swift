//
//  WiremockClientNetworkServiceTests.swift
//  WiremockClientTests
//
//  Created by Ted Rothrock on 2/15/21.
//

import XCTest
@testable import WiremockClient

class WiremockClientNetworkServiceTests: XCTestCase {
    
    private var networkService: WiremockClientNetworkService!
    private var urlSession: StubSynchronousURLSession!

    override func setUpWithError() throws {
        networkService = WiremockClientNetworkService()
        urlSession = StubSynchronousURLSession()
        networkService.urlSession = urlSession
    }

    override func tearDownWithError() throws {
        networkService = nil
        urlSession = nil
    }

    func test_makeSynchronousRequest_success() throws {
        XCTAssertNoThrow(try networkService.makeSynchronousRequest(with: WiremockEndpoint.resetServer))
    }
    
    func test_makeSynchronousRequest_error() throws {
        urlSession.error = WiremockClientError.networkError
        XCTAssertThrowsError(try networkService.makeSynchronousRequest(with: TestEndpoint.withoutResult))
    }
    
    func test_makeSynchronousRequest_invalidUrl() throws {
        XCTAssertThrowsError(try networkService.makeSynchronousRequest(with: TestEndpoint.withoutUrlRequest)) { error in
            XCTAssertEqual(error as? WiremockClientError, .invalidUrl)
        }
    }
    
    func test_makeSynchronousRequest_decodableResult_success() throws {
        let value = 99
        let result = TestCodable(value: value)
        let resultData = try XCTUnwrap(result.asData())
        urlSession.data = resultData
        let networkResult: TestCodable = try networkService.makeSynchronousRequest(with: TestEndpoint.withResult(result: result))
        XCTAssertEqual(networkResult.value, value)
    }
    
    func test_makeSynchronousRequest_decodableResult_networkError() throws {
        urlSession.error = WiremockClientError.networkError
        let result = TestCodable(value: 100)
        let throwingClosure: () throws -> Void = {
            let _ : TestCodable = try self.networkService.makeSynchronousRequest(with: TestEndpoint.withResult(result: result))
        }
        XCTAssertThrowsError(try throwingClosure())
    }
    
    func test_makeSynchronousRequest_decodableResult_invalidUrl() throws {
        let result = TestCodable(value: 100)
        let throwingClosure: () throws -> Void = {
            let _ : TestCodable = try self.networkService.makeSynchronousRequest(with: TestEndpoint.withResultWithoutUrlRequest(result: result))
        }
        XCTAssertThrowsError(try throwingClosure()) { error in
            XCTAssertEqual(error as? WiremockClientError, .invalidUrl)
        }
    }
    
    func test_makeSynchronousRequest_decodableResult_noData() throws {
        let result = TestCodable(value: 100)
        let throwingClosure: () throws -> Void = {
            let _ : TestCodable = try self.networkService.makeSynchronousRequest(with: TestEndpoint.withResult(result: result))
        }
        XCTAssertThrowsError(try throwingClosure()) { error in
            XCTAssertEqual(error as? WiremockClientError, .decodingError)
        }
    }

}

private class StubSynchronousURLSession: SynchronousURLSession {
    
    var data: Data?
    var error: Error?
    
    func executeSynchronousRequest(_ request: URLRequest) -> Result<Data?, Error> {
        if let error = error {
            return .failure(error)
        } else {
            return .success(data)
        }
    }
    
}

private enum TestEndpoint: Endpoint {
    case withoutResult
    case withResult(result: TestCodable)
    case withoutUrlRequest
    case withResultWithoutUrlRequest(result: TestCodable)
    
    var path: String {
        return "path"
    }
    
    var requestMethod: RequestMethod {
        return .POST
    }
    
    var body: Data? {
        return nil
    }
    
    var urlRequest: URLRequest? {
        switch self {
        case .withoutUrlRequest,
             .withResultWithoutUrlRequest:
            return nil
        default:
            guard let url = URL(string: "http://localhost:8080") else { return nil }
            return URLRequest(url: url)
        }
    }
    
}

private struct TestCodable: Codable {
    var value: Int
    
    func asData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: ["value": value], options: [.prettyPrinted])
    }
}
