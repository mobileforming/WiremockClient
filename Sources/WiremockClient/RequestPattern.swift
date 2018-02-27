//
//  RequestPattern.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

public enum URLMatchCondition: String {
    case urlEqualTo         = "url"
    case urlMatching        = "urlPattern"
    case urlPathEqualTo     = "urlPath"
    case urlPathMatching    = "urlPathPattern"
}

internal struct RequestPattern {
    
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
