//
//  StubMappingTests.swift
//  WiremockClientTests
//
//  Created by Ted Rothrock on 2/15/21.
//

import XCTest
@testable import WiremockClient

class StubMappingTests: XCTestCase {

    func test_requestMethods() throws {
        var mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "ANY")
        
        mapping = StubMapping.stubFor(requestMethod: .DELETE, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "DELETE")

        mapping = StubMapping.stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "GET")

        mapping = StubMapping.stubFor(requestMethod: .HEAD, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "HEAD")

        mapping = StubMapping.stubFor(requestMethod: .OPTIONS, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "OPTIONS")
 
        mapping = StubMapping.stubFor(requestMethod: .PATCH, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "PATCH")

        mapping = StubMapping.stubFor(requestMethod: .POST, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "POST")

        mapping = StubMapping.stubFor(requestMethod: .PUT, urlMatchCondition: .urlEqualTo, url: "")
        XCTAssertEqual(mapping.requestValue(for: RequestMapping.Constants.keyMethod), "PUT")
    }
    
    func test_urlMatchCondition() throws {
        var path = "test/path?param=0"
        var mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: path)
        XCTAssertEqual(mapping.requestValue(for: URLMatchCondition.urlEqualTo.rawValue), path)
        
        mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: path)
        XCTAssertEqual(mapping.requestValue(for: URLMatchCondition.urlMatching.rawValue), path)
        
        path = "test/path"
        mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlPathEqualTo, url: path)
        XCTAssertEqual(mapping.requestValue(for: URLMatchCondition.urlPathEqualTo.rawValue), path)
        
        path = "test/.*/path"
        mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlPathMatching, url: path)
        XCTAssertEqual(mapping.requestValue(for: URLMatchCondition.urlPathMatching.rawValue), path)
    }
    
    func test_withUUID() throws {
        let uuid = UUID()
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "").withUUID(uuid)
        XCTAssertEqual(mapping.topLevelValue(for: StubMapping.Constants.keyUuid), uuid.uuidString)
    }
    
    func test_withPriority() throws {
        let priority = 99
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "").withPriority(priority)
        XCTAssertEqual(mapping.topLevelValue(for: StubMapping.Constants.keyPriority), priority)
    }
    
    func test_inScenario() throws {
        let scenarioName = "testScenario"
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").inScenario(scenarioName)
        XCTAssertEqual(mapping.topLevelValue(for: StubMapping.Constants.keyScenName), scenarioName)
    }

    func test_whenScenarioStateIs() throws {
        let scenarioState = "testScenarioState"
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").whenScenarioStateIs(scenarioState)
        XCTAssertEqual(mapping.topLevelValue(for: StubMapping.Constants.keyReqScen), scenarioState)
    }
    
    func test_willSetStateTo() throws {
        let newScenarioState = "newScenarioState"
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").willSetStateTo(newScenarioState)
        XCTAssertEqual(mapping.topLevelValue(for: StubMapping.Constants.keyNewScen), newScenarioState)
    }
    
    func test_withHeader() throws {
        let key = "testKey"
        let value = "testValue"
        MatchCondition.allCases.forEach { condition in
            let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").withHeader(key, matchCondition: condition, value: value)
            XCTAssertTrue(mapping.verifySubdictionaryMatchCondition(dictionaryName: ResponseDefinition.Constants.keyHeaders, key: key, value: value, matchCondition: condition))
        }
    }
    
    func test_withCookie() throws {
        let key = "testKey"
        let value = "testValue"
        MatchCondition.allCases.forEach { condition in
            let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").withCookie(key, matchCondition: condition, value: value)
            XCTAssertTrue(mapping.verifySubdictionaryMatchCondition(dictionaryName: RequestMapping.Constants.keyCookies, key: key, value: value, matchCondition: condition))
        }
    }
    
    func test_withQueryParam() throws {
        let key = "testKey"
        let value = "testValue"
        MatchCondition.allCases.forEach { condition in
            let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").withQueryParam(key, matchCondition: condition, value: value)
            XCTAssertTrue(mapping.verifySubdictionaryMatchCondition(dictionaryName: RequestMapping.Constants.keyParams, key: key, value: value, matchCondition: condition))
        }
    }
    
    func test_withBasicAuth() throws {
        let username = "testUsername"
        let password = "testPassword"
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").withBasicAuth(username: username, password: password)
        
        let requestDict = try XCTUnwrap(mapping.asDict()[StubMapping.Constants.keyRequest] as? [String: Any])
        let authDict = try XCTUnwrap(requestDict[RequestMapping.Constants.keyBasicAuth] as? [String: Any])
        XCTAssertEqual(authDict[RequestMapping.Constants.keyUsername] as? String, username)
        XCTAssertEqual(authDict[RequestMapping.Constants.keyPassword] as? String, password)
    }
    
    func test_withRequestBody() throws {
        let value = "testValue"
        MatchCondition.allCases.forEach { condition in
            let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").withRequestBody(condition, value: value)
            guard let bodyPatternDict = mapping.getFirstBodyPattern(),
                  let actualValue = bodyPatternDict[condition.rawValue] as? String else {
                return XCTFail()
            }
            XCTAssertEqual(value, actualValue)
        }
    }
    
    func test_withRequestBodyEqualToJson() throws {
        let jsonString = "{ \"total_results\": 4 }"
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "").withRequestBodyEqualToJson(jsonString: jsonString, ignoreArrayOrder: false, ignoreExtraElements: true)
        let bodyPatternDict = try XCTUnwrap(mapping.getFirstBodyPattern())
        let jsonResult = try XCTUnwrap(bodyPatternDict[MatchCondition.equalToJson.rawValue] as? String)
        XCTAssertEqual(jsonString, jsonResult)
        let ignoreExtraElements = try XCTUnwrap(bodyPatternDict[RequestMapping.Constants.keyIgnoreExtraElements] as? Bool)
        XCTAssertTrue(ignoreExtraElements)
    }

    func test_withRequestBodyFromLocalJsonFile() throws {
        let jsonString = "{\"testKey\":\"testValue\"}"
        let fileName = "test"
        let mapping = StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlMatching, url: "")
            .withRequestBodyFromLocalJsonFile(fileName, in: Bundle(for: type(of: self)), ignoreArayOrder: true, ignoreExtraElements: true)
        let bodyPatternDict = try XCTUnwrap(mapping.getFirstBodyPattern())
        let jsonResult = try XCTUnwrap(bodyPatternDict[MatchCondition.equalToJson.rawValue] as? String)
        XCTAssertEqual(jsonString, jsonResult)
        let ignoreExtraElements = try XCTUnwrap(bodyPatternDict[RequestMapping.Constants.keyIgnoreExtraElements] as? Bool)
        XCTAssertTrue(ignoreExtraElements)
    }
}

private extension StubMapping {
    
    func topLevelValue<T>(for key: String) -> T? {
        return asDict()[key] as? T
    }
    
    func requestValue<T>(for key: String) -> T? {
        guard let requestDict = asDict()[StubMapping.Constants.keyRequest] as? [String: Any] else {
            return nil
        }
        return requestDict[key] as? T
    }
    
    func verifySubdictionaryMatchCondition(dictionaryName: String, key: String, value: String, matchCondition: MatchCondition) -> Bool {
        guard let requestDict = asDict()[StubMapping.Constants.keyRequest] as? [String: Any],
              let subDict = requestDict[dictionaryName] as? [String: Any],
              let keyDict = subDict[key] as? [String: Any],
              let actualValue = keyDict[matchCondition.rawValue] as? String else {
            return false
        }
        return value == actualValue
    }
    
    func getFirstBodyPattern() -> [String: Any]? {
        guard let requestDict = asDict()[StubMapping.Constants.keyRequest] as? [String: Any],
              let array = requestDict[RequestMapping.Constants.keyBodyPatterns] as? [[String: Any]] else {
            return nil
        }
        return array.first
    }
    
    func responseValue<T>(for key: String) -> T? {
        guard let requestDict = asDict()[StubMapping.Constants.keyResponse] as? [String: Any] else {
            return nil
        }
        return requestDict[key] as? T
    }
}
