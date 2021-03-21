//
//  WiremockClientTests.swift
//  WiremockClientTests
//
//  Created by Ted Rothrock on 2/12/21.
//

import XCTest
@testable import WiremockClient

class WiremockClientTests: XCTestCase {
    
    private var networkService: MockNetworkService!

    override func setUpWithError() throws {
        networkService = MockNetworkService()
        WiremockClient.networkService = networkService
    }

    override func tearDownWithError() throws {
        networkService = nil
    }
    
    private var stubLoggedRequests: [LoggedRequest] = {
        return [
            LoggedRequest(url: "/my/test/url",
                          absoluteUrl: "http://localhost:8080/my/test/url",
                          method: .POST,
                          body: "Test body",
                          browserProxyRequest: false,
                          loggedDateString: "2012-06-07 16:39:41",
                          headers: ["Accept": "text/plain", "Content-Type": "text/plain"])
        ]
    }()

    func test_postMapping() throws {
        try WiremockClient.postMapping(stubMapping: StubMapping.stubFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/test/path").willReturn(ResponseDefinition().withStatus(200)))
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/mappings")
        XCTAssertNotNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }

    func test_updateMapping() throws {
        let uuid = UUID()
        try WiremockClient.updateMapping(uuid: uuid, stubMapping: StubMapping.stubFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/test/path"))
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "PUT")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/mappings/\(uuid.uuidString)")
        XCTAssertNotNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_deleteMapping() throws {
        let uuid = UUID()
        try WiremockClient.deleteMapping(uuid: uuid)
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "DELETE")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/mappings/\(uuid.uuidString)")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_saveAllMappings() throws {
        try WiremockClient.saveAllMappings()
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/mappings/save")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_findRequests() throws {
        networkService.decodableResponse = LoggedRequestResponse(requests: stubLoggedRequests) 
        let _ = try WiremockClient.findRequests(requestMapping: RequestMapping.requestFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost/test/request"))
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/requests/find")
        XCTAssertNotNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_deleteAllRequests() throws {
        try WiremockClient.deleteAllRequests()
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "DELETE")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/requests")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_verifyRequestMapping_success() throws {
        networkService.decodableResponse = LoggedRequestResponse(requests: stubLoggedRequests)
        try WiremockClient.verify(requestMapping: RequestMapping.requestFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost/test/request"))
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/requests/find")
        XCTAssertNotNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_verifyRequestMapping_failure() throws {
        networkService.decodableResponse = LoggedRequestResponse(requests: [])
        XCTAssertThrowsError(try WiremockClient.verify(requestMapping: RequestMapping.requestFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost/test/request"))) { error in
            let wiremockClientError = try? XCTUnwrap(error as? WiremockClientError)
            guard case .verificationError = wiremockClientError else {
                return XCTFail()
            }
        }
    }
    
    func test_verifyRequestMappingExpectedCount_success() throws {
        networkService.decodableResponse = LoggedRequestResponse(requests: stubLoggedRequests)
        try WiremockClient.verify(expectedCount: 1, requestMapping: RequestMapping.requestFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost/test/request"))
        
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/requests/find")
        XCTAssertNotNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_verifyRequestMappingExpectedCount_failure() throws {
        networkService.decodableResponse = LoggedRequestResponse(requests: [])
        XCTAssertThrowsError(try WiremockClient.verify(expectedCount: 1, requestMapping: RequestMapping.requestFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "http://localhost/test/request"))) { error in
            let wiremockClientError = try? XCTUnwrap(error as? WiremockClientError)
            guard case .verificationError = wiremockClientError else {
                return XCTFail()
            }
        }
    }
    
    func test_isServerRunning_success() throws {
        networkService.decodableResponse = MappingsResponse(total: 1)
        XCTAssertTrue(try WiremockClient.isServerRunning())
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "GET")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/mappings")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_isServerRunning_failure() throws {
        XCTAssertThrowsError(try WiremockClient.isServerRunning()) { error in
            let wiremockClientError = try? XCTUnwrap(error as? WiremockClientError)
            guard case .decodingError = wiremockClientError else {
                return XCTFail()
            }
        }
    }
    
    func test_resetServer() throws {
        try WiremockClient.reset()
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/reset")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_resetAllScenarios() throws {
        try WiremockClient.resetAllScenarios()
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/scenarios/reset")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_shutDownServer() throws {
        try WiremockClient.shutdownServer()
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/shutdown")
        XCTAssertNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
    func test_setGlobalDelay() throws {
        try WiremockClient.setGlobalDelay(2000)
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(networkService.cachedEndpoint?.urlRequest?.url?.absoluteString, "http://localhost:8080/__admin/settings")
        XCTAssertNotNil(networkService.cachedEndpoint?.urlRequest?.httpBody)
    }
    
}

private class MockNetworkService: NetworkService {
    
    var cachedEndpoint: Endpoint?
    var decodableResponse: Decodable?
    
    func makeSynchronousRequest(with endpoint: Endpoint) throws {
        cachedEndpoint = endpoint
    }
    
    func makeSynchronousRequest<T: Decodable>(with endpoint: Endpoint) throws -> T {
        guard let decodableResponse = decodableResponse as? T else {
            throw WiremockClientError.decodingError
        }
        cachedEndpoint = endpoint
        return decodableResponse
    }
    
}
