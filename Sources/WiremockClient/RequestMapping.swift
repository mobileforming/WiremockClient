//
//  RequestMapping.swift
//  WiremockClientPackageDescription
//
//  Created by Tony Eichelberger on 10/30/18.
//

import Foundation

//----------------------------------
// MARK: Codable Request objects
//----------------------------------

/**
The example json from wiremock.org when only requests are returned.
 This is associated with the verify method:
 http://wiremock.org/docs/verifying
 
"url": "/my/other/url",
"absoluteUrl": "http://my.other.domain.com/my/other/url",
"method": "POST",
"headers": {
    "Accept": "text/plain",
    "Content-Type": "text/plain"
},
"body": "My text",
"browserProxyRequest": false,
"loggedDate": 1339083581823,
"loggedDateString": "2012-06-07 16:39:41"

 */

internal struct AllLoggedRequests: Codable {
    public var requests: [LoggedRequest]
}

public struct LoggedRequest: Codable {
    public var url: String?
    public var absoluteUrl: String?
    public var method: RequestMethod?
    public var body: String?
    public var browserProxyRequest: Bool?
    public var loggedDateString: String?
    public var headers: [String : String]?
}

/// An object used to configure a Wiremock request verification mapping. Refer to http://http://wiremock.org/docs/verifying/ for more details.
public class RequestMapping {
    
    private var request: RequestPattern
    
    private init(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) {
        self.request = RequestPattern(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
    }
    
    //----------------------------------
    // MARK: Mapping Builder Methods
    //----------------------------------
    
    /// Initializes a `RequestMapping`
    ///
    /// - Parameter requestMethod: The HTTP request method to match
    /// - Parameter urlMatchCondition: A condition used to match the URL path and parameters of a request to a mapping
    /// - Parameter url: The URL path and parameter pattern that the mapping will use to match requests
    /// - Returns: A configured `RequestMapping`
    public static func requestFor(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) -> RequestMapping {
        return RequestMapping(requestMethod: requestMethod, urlMatchCondition: urlMatchCondition, url: url)
    }
    
    /// Adds a header match condition to a mapping
    ///
    /// - Parameter key: The header key
    /// - Parameter matchCondition: The condition under which the header will be evaluated as a match
    /// - Parameter value: The header value
    /// - Returns: The `RequestMapping` with an updated header match condition
    public func withHeader(_ key: String, matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.headers = self.request.headers ?? [String: [String: String]]()
        let headerDict = [matchCondition.rawValue: value]
        self.request.headers?[key] = headerDict
        return self
    }
    
    /// Adds a cookie match condition to a mapping
    ///
    /// - Parameter key: The cookie key
    /// - Parameter matchCondition: The condition under which the cookie will be evaluated as a match
    /// - Parameter value: The cookie value
    /// - Returns: The `RequestMapping` with an updated cookie match condition
    public func withCookie(_ key: String, matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.cookies = self.request.cookies ?? [String: [String: String]]()
        let cookieDict = [matchCondition.rawValue: value]
        self.request.cookies?[key] = cookieDict
        return self
    }
    
    /// Adds a query parameter match condition to a mapping
    ///
    /// - Parameter param: The param key
    /// - Parameter matchCondition: The condition under which the param will be evaluated as a match
    /// - Parameter value: The param value
    /// - Returns: The `RequestMapping` with an updated param match condition
    public func withQueryParam(_ param: String, matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.queryParameters = self.request.queryParameters ?? [String: [String:Any]]()
        let paramDict = [matchCondition.rawValue: value]
        self.request.queryParameters?[param] = paramDict
        return self
    }
    
    /// Adds a basic authentication match condition to a mapping
    ///
    /// - Parameter username: The username to evaluate
    /// - Parameter password: The password to evaluate
    /// - Returns: The `RequestMapping` with an updated basic authentication match condition
    public func withBasicAuth(username: String, password: String) -> RequestMapping {
        self.request.basicAuthCredentials = ["username": username, "password": password]
        return self
    }
    
    /// Adds a request body match condition to a mapping
    ///
    /// - Parameter matchCondition: The condition under which the body will be evaluated as a match
    /// - Parameter value: The body value
    /// - Returns: The `RequestMapping` with an updated body match condition
    public func withRequestBody(_ matchCondition: MatchCondition, value: String) -> RequestMapping {
        self.request.bodyPatterns = self.request.bodyPatterns ?? [[String: Any]]()
        let bodyPatternDict = [matchCondition.rawValue: value]
        self.request.bodyPatterns?.append(bodyPatternDict)
        return self
    }
    
    /// Adds a request JSON match condition to a mapping
    ///
    /// - Parameter jsonString: The request JSON value in `String` form
    /// - Parameter ignoreArrayOrder: A flag that indicates if matching JSON must contain elements in an exact order
    /// - Parameter ignoreExtraElements: A flag that indicates if matching JSON must not contain extra elements
    /// - Returns: The `RequestMapping` with an updated JSON match condition
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

extension RequestMapping: CustomStringConvertible {
    /// A `String` representation of the mapping
    public var description: String {
        guard let data = asRequestData(), let stringVal = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return stringVal
    }
}
