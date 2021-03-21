//
//  NetworkService.swift
//  WiremockClientPackageDescription
//
//  Created by Ted Rothrock on 2/12/21.
//

import Foundation

protocol NetworkService {
    func makeSynchronousRequest(with endpoint: Endpoint) throws
    func makeSynchronousRequest<T: Decodable>(with endpoint: Endpoint) throws -> T
}
