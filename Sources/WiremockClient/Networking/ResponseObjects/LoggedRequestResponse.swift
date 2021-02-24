//
//  LoggedRequestResponse.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/23/21.
//

import Foundation

struct LoggedRequestResponse: Codable {
    var requests: [LoggedRequest]
}
