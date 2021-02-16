//
//  WiremockEndpoint.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/15/21.
//

import Foundation

enum WiremockEndpoint: Endpoint {
    case deleteMapping(uuid: UUID)
    case deleteRequestLog
    case getRequestLog(mapping: RequestMapping)
    case postMapping(mapping: StubMapping)
    case resetScenarios
    case resetServer
    case saveAllMappings
    case setGlobalDelay(delay: UInt)
    case shutDownServer
    case updateMapping(uuid: UUID, mapping: StubMapping)
    case verifyServerIsRunning
    
    var path: String {
        switch self {
        case .deleteMapping(let uuid):
            return "__admin/mappings/\(uuid.uuidString)"
        case .deleteRequestLog:
            return "__admin/requests"
        case .getRequestLog:
            return "__admin/requests/find"
        case .postMapping:
            return "__admin/mappings"
        case .resetScenarios:
            return "__admin/scenarios/reset"
        case .resetServer:
            return "__admin/reset"
        case .saveAllMappings:
            return "__admin/mappings/save"
        case .setGlobalDelay:
            return "__admin/settings"
        case .shutDownServer:
            return "__admin/shutdown"
        case .updateMapping(let uuid, _):
            return "__admin/mappings/\(uuid.uuidString)"
        case .verifyServerIsRunning:
            return "__admin/mappings"
        }
    }
    
    var requestMethod: RequestMethod {
        switch self {
        case .deleteMapping,
             .deleteRequestLog:
            return .DELETE
        case .getRequestLog,
             .postMapping,
             .resetScenarios,
             .resetServer,
             .saveAllMappings,
             .setGlobalDelay,
             .shutDownServer:
            return .POST
        case .updateMapping:
            return .PUT
        case .verifyServerIsRunning:
            return .GET
        }
    }
    
    var body: Data? {
        switch self {
        case .getRequestLog(let mapping):
            return mapping.asData()
        case .postMapping(let mapping):
            return mapping.asData()
        case .deleteMapping,
            .deleteRequestLog,
            .resetScenarios,
            .resetServer,
            .saveAllMappings,
            .shutDownServer,
            .verifyServerIsRunning:
            return nil
        case .setGlobalDelay(let delay):
            return try? JSONSerialization.data(withJSONObject: ["fixedDelay": delay], options: [.prettyPrinted])
        case .updateMapping(_, let mapping):
            return mapping.asData()
        }
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: "\(WiremockClient.baseURL)/\(path)") else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestMethod.rawValue
        urlRequest.httpBody = body
        return urlRequest
    }
}
