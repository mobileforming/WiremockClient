//
//  ResponseDefinitionTests.swift
//  WiremockClientTests
//
//  Created by Ted Rothrock on 2/15/21.
//

import XCTest
@testable import WiremockClient

class ResponseDefinitionTests: XCTestCase {

    func test_withHeader() throws {
        let key = "testKey"
        let value = "testValue"
        let response = ResponseDefinition().withHeader(key: key, value: value)
        let headers = try XCTUnwrap(response.asDict()[ResponseDefinition.Constants.keyHeaders] as? [String: Any])
        XCTAssertEqual(headers[key] as? String, value)
    }
    
    func test_withHeaders() throws {
        let key1 = "testKey1"
        let value1 = "testValue1"
        let key2 = "testKey2"
        let value2 = "testValue2"
        let headers = [key1: value1, key2: value2]
        let response = ResponseDefinition().withHeaders(headers)
        let responseHeaders = try XCTUnwrap(response.asDict()[ResponseDefinition.Constants.keyHeaders] as? [String: Any])
        XCTAssertEqual(responseHeaders[key1] as? String, value1)
        XCTAssertEqual(responseHeaders[key2] as? String, value2)
    }

    func test_withStatus() throws {
        let status = 200
        let response = ResponseDefinition().withStatus(status)
        XCTAssertEqual(response.asDict()[ResponseDefinition.Constants.keyStatus] as? Int, status)
    }
    
    func test_withStatusMessage() throws {
        let statusMessage = "OK"
        let response = ResponseDefinition().withStatusMessage(statusMessage)
        XCTAssertEqual(response.asDict()[ResponseDefinition.Constants.keyStatusMessage] as? String, statusMessage)
    }
    
    func test_withBody_string() throws {
        let bodyString = "Test body"
        let response = ResponseDefinition().withBody(bodyString)
        XCTAssertEqual(response.asDict()[ResponseDefinition.Constants.keyBody] as? String, bodyString)
    }
    
    func test_withBody_dict_success() throws {
        let key1 = "testKey1"
        let value1 = "testValue1"
        let bodyDict = [key1: value1]
        let response = ResponseDefinition().withBody(bodyDict)
        let responseBody = try XCTUnwrap(response.asDict()[ResponseDefinition.Constants.keyBody] as? String)
        XCTAssertTrue(responseBody.contains("\"\(key1)\":\"\(value1)\""))
    }
    
    func test_withBody_arrayOfDicts() throws {
        let key1 = "testKey1"
        let value1 = "testValue1"
        let key2 = "testKey2"
        let value2 = "testValue2"
        let dict1 = [key1: value1]
        let dict2 = [key2: value2]
        let response = ResponseDefinition().withBody([dict1, dict2])
        let responseBody = try XCTUnwrap(response.asDict()[ResponseDefinition.Constants.keyBody] as? String)
        XCTAssertTrue(responseBody.contains("{\"\(key1)\":\"\(value1)\"}"))
        XCTAssertTrue(responseBody.contains("{\"\(key2)\":\"\(value2)\"}"))
    }
    
    func test_withBody_invalidType() throws {
        let response = ResponseDefinition().withBody(99)
        XCTAssertNil(response.asDict()[ResponseDefinition.Constants.keyBody])
    }
    
    func test_withBodyFile() throws {
        let fileName = "testFile"
        let response = ResponseDefinition().withBodyFile(fileName)
        XCTAssertEqual(response.asDict()[ResponseDefinition.Constants.keyBodyFile] as? String, fileName)
    }
    
    func test_withLocalJsonBodyFile_success() throws {
        let bundle = Bundle(for: type(of: self))
        let response = ResponseDefinition().withLocalJsonBodyFile("test", in: bundle)
        let responseBody = try XCTUnwrap(response.asDict()[ResponseDefinition.Constants.keyBody] as? String)
        XCTAssertTrue(responseBody.contains("\"testKey\":\"testValue\""))
    }
    
    func test_withLocalJsonBodyFile_failure() throws {
        let bundle = Bundle(for: type(of: self))
        let response = ResponseDefinition().withLocalJsonBodyFile("noFile", in: bundle)
        XCTAssertNil(response.asDict()[ResponseDefinition.Constants.keyBody] as? String)
    }
    
    func test_proxiedFrom() throws {
        let proxyUrl = "http://localhost:8081"
        let response = ResponseDefinition().proxiedFrom(proxyUrl)
        XCTAssertEqual(response.asDict()[ResponseDefinition.Constants.keyProxyUrl] as? String, proxyUrl)
    }
    
    func test_withTransformers() throws {
        let response = ResponseDefinition().withTransformers([Transformer.responseTemplate])
        let transformers = try XCTUnwrap(response.asDict()[ResponseDefinition.Constants.keyTransformers] as? [String])
        let firstTransformer = try XCTUnwrap(transformers.first)
        XCTAssertEqual(firstTransformer, Transformer.responseTemplate.rawValue)
    }
    
    func test_withFixedDelay() throws {
        let response = ResponseDefinition().withFixedDelay(2)
        XCTAssertEqual(response.asDict()[ResponseDefinition.Constants.keyFixedDelay] as? Int, 2)
    }
}
