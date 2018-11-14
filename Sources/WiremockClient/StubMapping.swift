//
//  StubMapping.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

public enum MatchCondition: String {
    case equalTo, contains, matches, doesNotMatch, equalToJson, matchesJsonPath, equalToXml, matchesXPath
}

public class StubMapping {
    
    private var request: RequestMapping
    private var response: ResponseDefinition?
    private var uuid: UUID
    private var name: String?
    private var priority: Int?
    private var scenarioName: String?
    private var requiredScenarioState: String?
    private var newScenarioState: String?
    
    private init(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) {
        self.request = RequestMapping.requestFor(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
        self.uuid = UUID()
    }
    
    //----------------------------------
    // MARK: Mapping Builder Methods
    //----------------------------------
    
    public static func stubFor(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) -> StubMapping {
        return StubMapping(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
    }
    
    public func withUUID(_ uuid: UUID) -> StubMapping {
        self.uuid = uuid
        return self
    }
    
    public func withPriority(_ priority: Int) -> StubMapping {
        self.priority = priority
        return self
    }
    
    public func inScenario(_ scenarioName: String) -> StubMapping {
        self.scenarioName = scenarioName
        return self
    }
    
    public func whenScenarioStateIs(_ scenarioState: String) -> StubMapping {
        self.requiredScenarioState = scenarioState
        return self
    }
    
    public func willSetStateTo(_ scenarioState: String) -> StubMapping {
        self.newScenarioState = scenarioState
        return self
    }
    
    public func withHeader(_ key: String, matchCondition: MatchCondition, value: String) -> StubMapping {
        _ = self.request.withHeader(key, matchCondition: matchCondition, value: value)
        return self
    }
    
    public func withCookie(_ key: String, matchCondition: MatchCondition, value: String) -> StubMapping {
        _ = self.request.withCookie(key, matchCondition: matchCondition, value: value)
        return self
    }
    
    public func withQueryParam(_ param: String, matchCondition: MatchCondition, value: String) -> StubMapping {
        _ = self.request.withQueryParam(param, matchCondition: matchCondition, value: value)
        return self
    }
    
    public func withBasicAuth(username: String, password: String) -> StubMapping {
        _ = self.request.withBasicAuth(username: username, password: password)
        return self
    }
    
    public func withRequestBody(_ matchCondition: MatchCondition, value: String) -> StubMapping {
        _ = self.request.withRequestBody(matchCondition, value: value)
        return self
    }
    
    public func withRequestBodyEqualToJson(jsonString: String, ignoreArrayOrder: Bool, ignoreExtraElements: Bool) -> StubMapping {
        _ = self.request.withRequestBodyEqualToJson(jsonString: jsonString, ignoreArrayOrder: ignoreArrayOrder, ignoreExtraElements: ignoreExtraElements)
        return self
    }
    
    public func willReturn(_ response: ResponseDefinition?) -> StubMapping {
        self.response = response
        return self
    }
    
    //----------------------------------
    // MARK: Mapping to Data Conversion
    //----------------------------------
    
    // Mapping Key Names
    
    let keyUuid             = "uuid"
    let keyMethod           = "method"
    let keyPriority         = "priority"
    let keyScenName         = "scenarioName"
    let keyReqScen          = "requiredScenarioState"
    let keyNewScen          = "newScenarioState"
    let keyRequest          = "request"
    let keyBody             = "body"
    let keyStatus           = "status"
    let keyStatusMessage    = "statusMessage"
    let keyResponse         = "response"
    let keyParams           = "queryParameters"
    let keyBodyFile         = "bodyFileName"
    let keyProxyUrl         = "proxyBaseUrl"
    let keyHeaders          = "headers"
    let keyCookies          = "cookies"
    let keyBasicAuth        = "basicAuthCredentials"
    let keyBodyPatterns     = "bodyPatterns"
    
    internal func asData() -> Data? {
        
        var mappingDict = [String: Any]()
        
        // UUID
        
        mappingDict[keyUuid] = self.uuid.uuidString
        
        // Priority
        
        if let priority = self.priority {
            mappingDict[keyPriority] = priority
        }
        
        // Scenarios
        
        if let scenarioName = self.scenarioName {
            mappingDict[keyScenName] = scenarioName
        }
        
        if let requiredScenarioState = self.requiredScenarioState {
            mappingDict[keyReqScen] = requiredScenarioState
        }
        
        if let newScenarioState = self.newScenarioState {
            mappingDict[keyNewScen] = newScenarioState
        }
        
        /**** REQUEST ****/
        
        mappingDict[keyRequest] = self.request.requestDict()
        
        /**** RESPONSE ****/
        
        var responseDict = [String: Any]()
        
        if let response = self.response {
            
            // Body
            
            if let responseBody = response.body {
                responseDict[keyBody] = responseBody
            }
            
            // Status
            
            if let responseStatus = response.status {
                responseDict[keyStatus] = responseStatus
            }
            
            // Status Message
            
            if let statusMessage = response.statusMessage {
                responseDict[keyStatusMessage] = statusMessage
            }
            
            // Body File Name
            
            if let bodyFileName = response.bodyFileName {
                responseDict[keyBodyFile] = bodyFileName
            }
            
            // Proxy Base URL
            
            if let proxyBaseUrl = response.proxyBaseUrl {
                responseDict[keyProxyUrl] = proxyBaseUrl
            }
            
            // Headers
            
            if let headers = response.headers {
                responseDict[keyHeaders] = headers
            }
        }
        
        mappingDict[keyResponse] = responseDict
        
        return try? JSONSerialization.data(withJSONObject: mappingDict, options: [.prettyPrinted])
    }
}
