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

public class ResponseDefinition {
    
    internal var status: Int?
    internal var statusMessage: String?
    internal var body: String?
    internal var proxyBaseUrl: String?
    internal var bodyFileName: String?
    internal var headers: [String: String]?
    
    //----------------------------------
    // MARK: Response Builder Methods
    //----------------------------------
    
    public func withHeader(key: String, value: String) -> ResponseDefinition {
        self.headers = self.headers ?? [String: String]()
        self.headers?[key] = value
        return self
    }
    
    public func withStatus(_ status: Int) -> ResponseDefinition {
        self.status = status
        return self
    }
    
    public func withStatusMessage(_ statusMessage: String) -> ResponseDefinition {
        self.statusMessage = statusMessage
        return self
    }
    
    public func withBody(_ body: Any) -> ResponseDefinition {
        switch body {
        
        case let string as String:
            self.body = string
            break
            
        case let json as [String: Any]:
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                guard let jsonString = String(data: data, encoding: .utf8) else {throw ResponseDefintionError.unableToConvertData}
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
    
    public func withBodyFile(_ fileName: String) -> ResponseDefinition {
        self.bodyFileName = fileName
        return self
    }
    
    public func withLocalJsonBodyFile(fileName: String, fileBundleId: String, fileSubdirectory: String?) -> ResponseDefinition {
        do {
            guard let bundle = Bundle(identifier: fileBundleId) else {throw ResponseDefintionError.missingBundle}
            guard let responseUrl = bundle.url(forResource: fileName, withExtension: "json", subdirectory: fileSubdirectory) else {throw ResponseDefintionError.fileNotFound}
            
            let data = try Data(contentsOf: responseUrl)
            let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            let dataWithoutSpecialChars = try JSONSerialization.data(withJSONObject: json, options: [])
            guard let jsonString = String(data: dataWithoutSpecialChars, encoding: .utf8) else {throw ResponseDefintionError.unableToConvertData}
            self.body = jsonString
        } catch {
            print("Error adding body to ResponseDefinition from file \(fileName): \(error.localizedDescription)")
        }
        return self
    }
    
    public func proxiedFrom(_ urlString: String) -> ResponseDefinition {
        self.proxyBaseUrl = urlString
        return self
    }
}
