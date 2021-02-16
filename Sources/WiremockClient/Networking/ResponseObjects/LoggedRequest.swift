//
//  LoggedRequest.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/12/21.
//

import Foundation

/**
The example json from wiremock.org when only requests are returned.
 This is associated with the verify method:
 http://wiremock.org/docs/verifying
 
"url": "/my/other/url",
"absoluteUrl": "http://my.other.domain.com/my/other/url",
"method": "POST",
"headers": {
    "Accept": "text/plain",
    "Content-Type": "text/plain"
},
"body": "My text",
"browserProxyRequest": false,
"loggedDate": 1339083581823,
"loggedDateString": "2012-06-07 16:39:41"

 */

/// An object representing an entry in the Wiremock server's request journal.
public struct LoggedRequest: Codable {
    public var url: String?
    public var absoluteUrl: String?
    public var method: RequestMethod?
    public var body: String?
    public var browserProxyRequest: Bool?
    public var loggedDateString: String?
    public var headers: [String : String]?
}
