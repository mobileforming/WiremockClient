//
//  ResponseDefinition.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 6/23/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

private enum ResponseDefintionError: Error {
    case missingBundle
    case fileNotFound
    case unableToConvertData
}

extension ResponseDefintionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingBundle:
            return "Unable to locate resource bundle."
        case .fileNotFound:
            return "Unable to locate file in resource bundle."
        case .unableToConvertData:
            return "Unable to convert data to string."
        }
    }
}

/// An object used to define the response to be returned by a Wiremock server. Refer to http://http://wiremock.org/docs/stubbing/ for more details.
public class ResponseDefinition {
    
    var status: Int?
    var fixedDelay: Int?
    var statusMessage: String?
    var body: String?
    var proxyBaseUrl: String?
    var bodyFileName: String?
    var headers: [String: String]?
    var transformers: [Transformer]?
    
    public init() {}

    //----------------------------------
    // MARK: Response Builder Methods
    //----------------------------------
    
    /// Adds a header to the Wiremock server response
    ///
    /// - Parameter key: The header key
    /// - Parameter value: The header value
    /// - Returns: The `ResponseDefinition` with updated headers
    public func withHeader(key: String, value: String) -> ResponseDefinition {
        self.headers = self.headers ?? [String: String]()
        self.headers?[key] = value
        return self
    }
    
    /// Adds multiple headers to the Wiremock server response
    ///
    /// - Parameter headers: The headers to add
    /// - Returns: The `ResponseDefinition` with updated headers
    public func withHeaders(_ headers: [String: String] = [:]) -> ResponseDefinition {
        self.headers = headers
        return self
    }
    
    /// Updates the HTTP status code of the Wiremock server response
    ///
    /// - Parameter status: An HTTP status code
    /// - Returns: The `ResponseDefinition` with an updated status code
    public func withStatus(_ status: Int) -> ResponseDefinition {
        self.status = status
        return self
    }
    
    /// Updates the `statusMessage` of the Wiremock server response
    ///
    /// - Parameter statusMessage: A status message
    /// - Returns: The `ResponseDefinition` with an updated status message
    public func withStatusMessage(_ statusMessage: String) -> ResponseDefinition {
        self.statusMessage = statusMessage
        return self
    }
    
    /// Updates the body of the Wiremock server response
    ///
    /// - Parameter body: The body to return. Supported objects include `String`, `[String: Any]`, and `[[String: Any]]`.
    /// - Returns: The `ResponseDefinition` with an updated body
    public func withBody(_ body: Any) -> ResponseDefinition {
        switch body {
        
        case let string as String:
            self.body = string
            break
            
        case let json as [String: Any]:
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    throw ResponseDefintionError.unableToConvertData
                }
                self.body = jsonString
            } catch {
                print("Error adding body to ResponseDefinition: \(error.localizedDescription)")
            }
            break
            
        case let json as [[String: Any]]:
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    throw ResponseDefintionError.unableToConvertData
                }
                self.body = jsonString
            } catch {
                print("Error adding body to ResponseDefinition: \(error.localizedDescription)")
            }
            break

        default:
            print("Unable to handle response body of type \(type(of: body))")
            break
        }
        return self
    }
    
    /// Updates the Wiremock server file name with which to populate the response body
    ///
    /// - Parameter fileName: The name of a file located in the __files directory of the Wiremock server. Its contents will be used to populate the response body.
    /// - Returns: The `ResponseDefinition` with an updated body file name
    public func withBodyFile(_ fileName: String) -> ResponseDefinition {
        self.bodyFileName = fileName
        return self
    }
    
    /// Updates the body of the Wiremock server response using the contents of a local JSON file.
    /// - Parameters:
    ///   - fileName: The name of a local JSON file. Its contents will be used to populate the reponse body.
    ///   - bundle: The `Bundle` in which the JSON file is located.
    ///   - subdirectory: The path to the file.
    /// - Returns: The `ResponseDefinition` with an updated local JSON body file
    public func withLocalJsonBodyFile(_ fileName: String, in bundle: Bundle, subdirectory: String? = nil) -> ResponseDefinition {
        do {
            guard let responseUrl = bundle.url(forResource: fileName, withExtension: "json", subdirectory: subdirectory) else {
                throw ResponseDefintionError.fileNotFound
            }
            let data = try Data(contentsOf: responseUrl)
            let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            let dataWithoutSpecialChars = try JSONSerialization.data(withJSONObject: json, options: [])
            guard let jsonString = String(data: dataWithoutSpecialChars, encoding: .utf8) else {
                throw ResponseDefintionError.unableToConvertData
            }
            self.body = jsonString
        } catch {
            print("Error adding body to ResponseDefinition from file \(fileName): \(error.localizedDescription)")
        }
        return self
    }
    
    /// Updates the proxy URL from which the response is returned. Matching requests will be proxied to this URL.
    ///
    /// - Parameter urlString: The proxy URL string
    /// - Returns: The `ResponseDefinition` with an updated proxy URL
    public func proxiedFrom(_ urlString: String) -> ResponseDefinition {
        self.proxyBaseUrl = urlString
        return self
    }
    
    /// Updates the array of `Transformer` options included in the response
    ///
    /// - Parameter transformers: The `Transformer` options to include
    /// - Returns: The `ResponseDefinition` with updated `Transformer` options
    public func withTransformers(_ transformers: [Transformer]) -> ResponseDefinition {
        self.transformers = transformers
        return self
    }

    /// Adds a delay to a specific response
    ///
    /// - Parameter fixedDelay: The time interval in milliseconds by which to delay the response
    /// - Returns: The `ResponseDefinition` with added delay to it
    public func withFixedDelay(_ fixedDelay: Int) -> ResponseDefinition {
        self.fixedDelay = fixedDelay
        return self
    }
    
    //----------------------------------
    // MARK: Mapping to Data Conversion
    //----------------------------------
    
    enum Constants {
        static let keyBody             = "body"
        static let keyBodyFile         = "bodyFileName"
        static let keyHeaders          = "headers"
        static let keyProxyUrl         = "proxyBaseUrl"
        static let keyStatus           = "status"
        static let keyStatusMessage    = "statusMessage"
        static let keyTransformers     = "transformers"
        static let keyFixedDelay       = "fixedDelayMilliseconds"
    }
    
    func asDict() -> [String: Any] {
        var responseDict = [String: Any]()
        
        // Body
        if let responseBody = body {
            responseDict[Constants.keyBody] = responseBody
        }
        
        // Status
        if let responseStatus = status {
            responseDict[Constants.keyStatus] = responseStatus
        }
        
        // Status Message
        if let statusMessage = statusMessage {
            responseDict[Constants.keyStatusMessage] = statusMessage
        }
        
        // Body File Name
        if let bodyFileName = bodyFileName {
            responseDict[Constants.keyBodyFile] = bodyFileName
        }
        
        // Proxy Base URL
        if let proxyBaseUrl = proxyBaseUrl {
            responseDict[Constants.keyProxyUrl] = proxyBaseUrl
        }
        
        // Headers
        if let headers = headers {
            responseDict[Constants.keyHeaders] = headers
        }
        
        // Transformers
        if let transformers = transformers {
            responseDict[Constants.keyTransformers] = transformers.map { $0.rawValue }
        }
        
        // Fixed Delay
        if let fixedDelay = fixedDelay {
            responseDict[Constants.keyFixedDelay] = fixedDelay
        }
        
        return responseDict
    }
}
