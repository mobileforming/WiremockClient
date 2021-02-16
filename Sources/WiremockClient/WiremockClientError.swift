//
//  WiremockClientError.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/12/21.
//

import Foundation

enum WiremockClientError: Error {
    case invalidUrl
    case verificationError(description: String)
    case decodingError
    case networkError
}

extension WiremockClientError: Equatable {
    static func == (lhs: WiremockClientError, rhs: WiremockClientError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUrl, .invalidUrl):
            return true
        case (.verificationError(let desc1), .verificationError(let desc2)):
            return desc1 == desc2
        case (.decodingError, .decodingError):
            return true
        case (.networkError, .networkError):
            return true
        default:
            return false
        }
    }
}
