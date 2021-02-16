//
//  RequestMethod.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

/// A collection of HTTP request methods
public enum RequestMethod: String, Codable {
    case GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD, TRACE, ANY
}
