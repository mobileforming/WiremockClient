//
//  RequestMapping.swift
//  WiremockClientPackageDescription
//
//  Created by Tony Eichelberger on 10/30/18.
//

import Foundation

/// An object used to configure a Wiremock request verification mapping. Refer to http://http://wiremock.org/docs/verifying/ for more details.
public class RequestMapping {
    
    private(set) var request: RequestPattern
    
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
        self.request.basicAuthCredentials = [Constants.keyUsername: username, Constants.keyPassword: password]
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
            bodyPatternDict[Constants.keyIgnoreArrayOrder] = true
        }
        if ignoreExtraElements {
            bodyPatternDict[Constants.keyIgnoreExtraElements] = true
        }
        self.request.bodyPatterns?.append(bodyPatternDict)
        return self
    }
    
    //----------------------------------
    // MARK: Mapping to Data Conversion
    //----------------------------------
    
    // Mapping Key Names
    
    enum Constants {
        static let keyMethod                = "method"
        static let keyParams                = "queryParameters"
        static let keyHeaders               = "headers"
        static let keyCookies               = "cookies"
        static let keyBasicAuth             = "basicAuthCredentials"
        static let keyBodyPatterns          = "bodyPatterns"
        static let keyIgnoreArrayOrder      = "ignoreArrayOrder"
        static let keyIgnoreExtraElements   = "ignoreExtraElements"
        static let keyUsername              = "username"
        static let keyPassword              = "password"
    }
    
    func asDict() -> [String: Any] {
        var requestDict = [String: Any]()
        
        // URL
        requestDict["\(self.request.urlPattern.urlMatchCondition.rawValue)"] = "\(self.request.urlPattern.url)"
        
        // Request Method
        requestDict[Constants.keyMethod] = "\(self.request.requestMethod.rawValue)"
        
        // Headers
        if let headers = self.request.headers {
            requestDict[Constants.keyHeaders] = headers
        }
        
        // Cookies
        if let cookies = self.request.cookies {
            requestDict[Constants.keyCookies] = cookies
        }
        
        // Query Parameters
        if let queryParameters = self.request.queryParameters {
            requestDict[Constants.keyParams] = queryParameters
        }
        
        // Basic Auth Credentials
        if let credentials = self.request.basicAuthCredentials {
            requestDict[Constants.keyBasicAuth] = credentials
        }
        
        // Request Body Patterns
        if let bodyPatterns = self.request.bodyPatterns {
            requestDict[Constants.keyBodyPatterns] = bodyPatterns
        }
        
        return requestDict
    }
    
    func asData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: asDict(), options: [.prettyPrinted])
    }
    
}

extension RequestMapping: CustomStringConvertible {
    /// A `String` representation of the mapping
    public var description: String {
        guard let data = asData(), let stringVal = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return stringVal
    }
}
