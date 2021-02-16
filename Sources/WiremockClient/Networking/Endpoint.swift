//
//  Endpoint.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/15/21.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var requestMethod: RequestMethod { get }
    var body: Data? { get }
    var urlRequest: URLRequest? { get }
}
