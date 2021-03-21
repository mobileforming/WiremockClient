//
//  IntegrationTests.swift
//  WiremockClientTests
//
//  Created by Ted Rothrock on 2/23/21.
//

import XCTest
import WiremockClient

// Successful execution of this test suite requires a Wiremock server instance running on localhost:8080.

class IntegrationTests: XCTestCase {

    override func setUpWithError() throws {
        guard try WiremockClient.isServerRunning() else {
            return XCTFail()
        }
    }

    override func tearDownWithError() throws {
        try WiremockClient.reset()
    }

    func test_post_update_deleteMapping() throws {
        let urlString = "http://localhost:8080/test/path"
        let mappingID = UUID()
        
        // Post a mapping
        try WiremockClient
            .postMapping(stubMapping: StubMapping
                            .stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/test/path")
                            .withUUID(mappingID)
                            .willReturn(ResponseDefinition()
                                            .withBody(["key": "value"])
                                            .withStatus(200)))
        
        let exp1 = XCTestExpectation(description: "Wait for network request")
        var json1: [String: String]?
        
        // Query the mapping
        executeNetworkRequest(with: urlString) { result in
            json1 = result
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 1.0)
        
        // Verify the result
        let unwrapped1 = try XCTUnwrap(json1)
        XCTAssertEqual(unwrapped1["key"], "value")
        
        // Update the mapping
        try WiremockClient.updateMapping(uuid: mappingID, stubMapping: StubMapping
                                            .stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/test/path")
                                            .willReturn(ResponseDefinition()
                                                            .withBody(["otherKey": "otherValue"])
                                                            .withStatus(200)))
        
        let exp2 = XCTestExpectation(description: "Wait for network request")
        var json2: [String: String]?
        
        // Query the mapping again
        executeNetworkRequest(with: urlString) { result in
            json2 = result
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)
        
        // Verify the result
        let unwrapped2 = try XCTUnwrap(json2)
        XCTAssertEqual(unwrapped2["otherKey"], "otherValue")
        
        // Delete the mapping
        try WiremockClient.deleteMapping(uuid: mappingID)
        
        let exp3 = XCTestExpectation(description: "Wait for network request")
        var json3: [String: String]?
        
        // Query the mapping again
        executeNetworkRequest(with: urlString) { result in
            json3 = result
            exp3.fulfill()
        }
        wait(for: [exp3], timeout: 1.0)
        
        // Verify that nothing is returned.
        XCTAssertNil(json3)
    }
    
    func test_requestQueries() throws {
        let urlString = "http://localhost:8080/test/path"
        
        // Make a request.
        let exp1 = XCTestExpectation(description: "Wait for network request")
        executeNetworkRequest(with: urlString) { _ in
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 1.0)
        
        // Verify that the request was registered.
        let requestMapping = RequestMapping.requestFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/test/path")
        try WiremockClient.verify(requestMapping: requestMapping)
        
        // Make another request
        let exp2 = XCTestExpectation(description: "Wait for network request")
        executeNetworkRequest(with: urlString) { _ in
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)
        
        // Verify request count
        try WiremockClient.verify(expectedCount: 2, requestMapping: requestMapping)
    }
    
    // MARK: Networking

    private func executeNetworkRequest(with urlString: String, completion: @escaping ([String: String]?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            guard let data = data else {
                completion(nil)
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
            completion(json)
        }
        task.resume()
    }
}
