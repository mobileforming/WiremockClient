//
//  RequestPattern.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

/// Conditions used to match the URL path and parameters of a request to a mapping
public enum URLMatchCondition: String {
    
    /// Exact match of both path and query parameters
    case urlEqualTo         = "url"
    
    /// Match by path and query parameters with option to include regex
    case urlMatching        = "urlPattern"
    
    /// Exact match by path only
    case urlPathEqualTo     = "urlPath"
    
    /// Match by path with option to include regex
    case urlPathMatching    = "urlPathPattern"
}

struct RequestPattern {
    var urlPattern: UrlPattern
    var requestMethod: RequestMethod
    var queryParameters: [String: [String: Any]]?
    var headers: [String: [String: String]]?
    var cookies: [String: [String: String]]?
    var basicAuthCredentials: [String: String]?
    var bodyPatterns: [[String: Any]]?
    
    init(requestMethod: RequestMethod, urlMatchCondition: URLMatchCondition, url: String) {
        self.requestMethod = requestMethod
        self.urlPattern = UrlPattern(url: url, urlMatchCondition: urlMatchCondition)
    }
}
