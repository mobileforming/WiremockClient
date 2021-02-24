//
//  WiremockClient.swift
//  NewWiremockClient
//
//  Created by Ted Rothrock on 6/24/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

public struct WiremockClient {
    
    /// The URL at which the Wiremock instance to be configured is running.
    public static var baseURL = "http://localhost:8080"
    
    /// A service responsible for executing network requests. Only overridable for test purposes.
    @DebugOverridable
    static var networkService: NetworkService = WiremockClientNetworkService()
}

// MARK: - Mappings

extension WiremockClient {

    /// Adds a stub mapping to the Wiremock server.
    ///
    /// - Parameter stubMapping: The stub mapping to add
    public static func postMapping(stubMapping: StubMapping) throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.postMapping(mapping: stubMapping))
    }

    /// Replaces a stub mapping on the Wiremock server.
    ///
    /// - Parameter uuid: The identifier of the mapping to replace
    public static func updateMapping(uuid: UUID, stubMapping: StubMapping) throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.updateMapping(uuid: uuid, mapping: stubMapping))
    }

    /// Deletes a stub mapping from the Wiremock server.
    ///
    /// - Parameter uuid: The identifier of the mapping to delete
    public static func deleteMapping(uuid: UUID) throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.deleteMapping(uuid: uuid))
    }

    /// Persists all stub mappings to the `mappings` directory of the Wiremock server.
    public static func saveAllMappings() throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.saveAllMappings)
    }

}

// MARK: - Requests

extension WiremockClient {

    /// Looks up all requests matching a given pattern.
    ///
    /// - Parameter requestMapping: The request mapping to filter on
    /// - Returns: An array of LoggedRequest objects or an empty array if there was no match
    public static func findRequests(requestMapping: RequestMapping) throws -> [LoggedRequest] {
        let response: LoggedRequestResponse = try networkService.makeSynchronousRequest(with: WiremockEndpoint.getRequestLog(mapping: requestMapping))
        return response.requests
    }

    /// Deletes all requests that have been recorded to this point
    public static func deleteAllRequests() throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.deleteRequestLog)
    }
    
    /// Verifies that a request has been made to the Wiremock server at least once.
    ///
    /// - Parameter mapping: The request mapping to filter on
    /// - Throws: A verfication error if there was no matching request
    public static func verify(requestMapping: RequestMapping) throws {
        let requests = try findRequests(requestMapping: requestMapping)
        if requests.count < 1 {
            throw WiremockClientError.verificationError(description: "Did not find a matching request for the \(requestMapping) pattern")
        }
    }
    
    /// Verifies that a request has been made to the Wiremock server a specific number of times.
    ///
    /// - Parameter mapping: The request mapping to filter on
    /// - Throws: A verfication error if the request was not matched the expected number of times
    public static func verify(expectedCount: UInt, requestMapping: RequestMapping) throws {
        let requests = try findRequests(requestMapping: requestMapping)
        if requests.count != expectedCount  {
            throw WiremockClientError.verificationError(description: "Did not find a matching request for the \(requestMapping) pattern")
        }
    }
    
}

// MARK: - Server State

extension WiremockClient {
    
    /// Verifies that the server is running.
    ///
    /// - Returns: true if the server is running and ready to interact with
    public static func isServerRunning() throws -> Bool {
        let mappingsResponse: MappingsResponse = try networkService.makeSynchronousRequest(with: WiremockEndpoint.verifyServerIsRunning)
        return mappingsResponse.isServerRunning
    }

    /// Removes all stub mappings and deletes request logs from the Wiremock server.
    public static func reset() throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.resetServer)
    }
    
    /// Resets the state of all scenarios to `start`.
    public static func resetAllScenarios() throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.resetScenarios)
    }
    
    /// Shuts down the Wiremock server.
    public static func shutdownServer() throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.shutDownServer)
    }
    
    /// Adds a delay to all responses from the Wiremock server.
    ///
    /// - Parameter delay: The time interval in milliseconds by which to delay all responses
    public static func setGlobalDelay(_ delay: UInt) throws {
        try networkService.makeSynchronousRequest(with: WiremockEndpoint.setGlobalDelay(delay: delay))
    }
}
