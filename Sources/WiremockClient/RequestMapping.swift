//
//  RequestMapping.swift
//  WiremockClientPackageDescription
//
//  Created by Tony Eichelberger on 10/30/18.
//

import Cocoa

public class RequestMapping {
    
    private var request: RequestPattern
    
    private init(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) {
        self.request = RequestPattern(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
    }
    
    //----------------------------------
    // MARK: Mapping Builder Methods
    //----------------------------------
    
    public static func requestFor(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) -> RequestMapping {
        return RequestMapping(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
    }
    
    public func withHeader(_ key: String, matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.headers = self.request.headers ?? [String: [String: String]]()
        let headerDict = [matchCondition.rawValue: value]
        self.request.headers?[key] = headerDict
        return self
    }
    
    public func withCookie(_ key: String, matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.cookies = self.request.cookies ?? [String: [String: String]]()
        let cookieDict = [matchCondition.rawValue: value]
        self.request.cookies?[key] = cookieDict
        return self
    }
    
    public func withQueryParam(_ param: String, matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.queryParameters = self.request.queryParameters ?? [String: [String:Any]]()
        let paramDict = [matchCondition.rawValue: value]
        self.request.queryParameters?[param] = paramDict
        return self
    }
    
    public func withBasicAuth(username: String, password: String) -> RequestMapping {
        self.request.basicAuthCredentials = ["username": username, "password": password]
        return self
    }
    
    public func withRequestBody(_ matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.bodyPatterns = self.request.bodyPatterns ?? [[String: Any]]()
        let bodyPatternDict = [matchCondition.rawValue: value]
        self.request.bodyPatterns?.append(bodyPatternDict)
        return self
    }
    
    public func withRequestBodyEqualToJson(jsonString: String, ignoreArrayOrder: Bool, ignoreExtraElements: Bool) -> RequestMapping {
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

    //----------------------------------
    // MARK: Mapping to Data Conversion
    //----------------------------------
    
    // Mapping Key Names
    
    let keyMethod           = "method"
    let keyParams           = "queryParameters"
    let keyHeaders          = "headers"
    let keyCookies          = "cookies"
    let keyBasicAuth        = "basicAuthCredentials"
    let keyBodyPatterns     = "bodyPatterns"
    
    internal func requestDict() -> [String: Any] {
        
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
        
        return requestDict
    }
    
    internal func asRequestData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: requestDict(), options: [.prettyPrinted])
    }

    
}
