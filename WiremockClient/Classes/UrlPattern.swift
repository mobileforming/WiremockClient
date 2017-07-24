//
//  UrlPattern.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

internal struct UrlPattern {
    
    var url: String
    var urlMatchCondition: URLMatchCondition
    
    init(url: String, urlMatchCondition: URLMatchCondition) {
        self.url = url
        self.urlMatchCondition = urlMatchCondition
    }
}
