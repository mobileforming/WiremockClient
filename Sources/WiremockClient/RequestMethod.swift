//
//  RequestMethod.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

public enum RequestMethod: String, Codable {
    case GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD, TRACE, ANY
}
