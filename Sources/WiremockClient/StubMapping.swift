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
    
    private var request: RequestPattern
    private var response: ResponseDefinition?
    private var uuid: UUID
    private var name: String?
    private var priority: Int?
    private var scenarioName: String?
    private var requiredScenarioState: String?
    private var newScenarioState: String?
    
    private init(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) {
        self.request = RequestPattern(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
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
        self.request.headers = self.request.headers ?? [String: [String: String]]()
        let headerDict = [matchCondition.rawValue: value]
        self.request.headers?[key] = headerDict
        return self
    }
    
    public func withCookie(_ key: String, matchCondition: MatchCondition, value: String) -> StubMapping {
        self.request.cookies = self.request.cookies ?? [String: [String: String]]()
        let cookieDict = [matchCondition.rawValue: value]
        self.request.cookies?[key] = cookieDict
        return self
    }
    
    public func withQueryParam(_ param: String, matchCondition: MatchCondition, value: String) -> StubMapping {
        self.request.queryParameters = self.request.queryParameters ?? [String: [String:Any]]()
        let paramDict = [matchCondition.rawValue: value]
        self.request.queryParameters?[param] = paramDict
        return self
    }
    
    public func withBasicAuth(username: String, password: String) -> StubMapping {
        self.request.basicAuthCredentials = ["username": username, "password": password]
        return self
    }
    
    public func withRequestBody(_ matchCondition: MatchCondition, value: String) -> StubMapping {
        self.request.bodyPatterns = self.request.bodyPatterns ?? [[String: Any]]()
        let bodyPatternDict = [matchCondition.rawValue: value]
        self.request.bodyPatterns?.append(bodyPatternDict)
        return self
    }
    
    public func withRequestBodyEqualToJson(jsonString: String, ignoreArrayOrder: Bool, ignoreExtraElements: Bool) -> StubMapping {
        self.request.bodyPatterns = self.request.bodyPatterns ?? [[String: Any]]()
        var bodyPatternDict: [String: Any] = [MatchCondition.equalToJson.rawValue: jsonString]
        if ignoreArrayOrder {
            bodyPatternDict["ignoreArrayOrder"] = true
        }
        if ignoreExtraElements {
            bodyPatternDict["ignoreExtraElements"] = true
        }
        self.request.bodyPatterns?.append(bodyPatternDict)
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
        
        var requestDict = [String: Any]()
        
        // URL
        
        requestDict["\(self.request.urlPattern.urlMatchCondition.rawValue)"] = "\(self.request.urlPattern.url)"
        
        // Request Method
        
        requestDict[keyMethod] = "\(self.request.requestMethod.rawValue)"
        
        // Headers
        
        if let headers = self.request.headers {
            requestDict[keyHeaders] = headers
        }
        
        // Cookies
        
        if let cookies = self.request.cookies {
            requestDict[keyCookies] = cookies
        }
        
        // Query Parameters
        
        if let queryParameters = self.request.queryParameters {
            requestDict[keyParams] = queryParameters
        }
        
        // Basic Auth Credentials
        
        if let credentials = self.request.basicAuthCredentials {
            requestDict[keyBasicAuth] = credentials
        }
        
        // Request Body Patterns
        
        if let bodyPatterns = self.request.bodyPatterns {
            requestDict[keyBodyPatterns] = bodyPatterns
        }
        
        mappingDict[keyRequest] = requestDict
        
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
