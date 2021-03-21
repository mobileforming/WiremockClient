//
//  MatchCondition.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/15/21.
//

import Foundation

/// A collection of conditons used to determine matches based on request attributes including headers, cookies, parameters, request body, JSON, XML, and XPath
public enum MatchCondition: String, CaseIterable {
    /// An exact match
    case equalTo
    
    /// A match containing a value
    case contains
    
    /// A match by regex pattern
    case matches
    
    /// A negative match
    case doesNotMatch
    
    /// A semantic match of valid JSON
    case equalToJson
    
    /// A JSON attribute non-nil value match
    case matchesJsonPath
    
    /// A semantic match of valid XML
    case equalToXml
    
    /// An XML path non-nil value match
    case matchesXPath
}
