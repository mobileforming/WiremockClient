//
//  WiremockClient.swift
//  NewWiremockClient
//
//  Created by Ted Rothrock on 6/24/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

enum WiremockClientError: Error {
    case verficationError(String)
}

public struct WiremockClient {
    
    public static var baseURL = "http://localhost:8080"
    
    /// Adds a stub mapping to the Wiremock server.
    ///
    /// - Parameter stubMapping: The stub mapping to add
    public static func postMapping(stubMapping: StubMapping) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        request.httpBody = stubMapping.asData()
        _ = makeSynchronousRequest(request: request, errorMessagePrefix: "Error posting mapping")
    }
    
    /// Replaces a stub mapping on the Wiremock server.
    ///
    /// - Parameter uuid: The identifier of the mapping to replace
    public static func updateMapping(uuid: UUID, stubMapping: StubMapping) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/\(uuid.uuidString)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.PUT.rawValue
        request.httpBody = stubMapping.asData()
        _ = makeSynchronousRequest(request: request, errorMessagePrefix: "Error updating mapping")
    }
    
    /// Deletes a stub mapping from the Wiremock server.
    ///
    /// - Parameter uuid: The identifier of the mapping to delete
    public static func deleteMapping(uuid: UUID) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/\(uuid.uuidString)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.DELETE.rawValue
        _ = makeSynchronousRequest(request: request, errorMessagePrefix: "Error deleting mapping")
    }
    
    
    /// Verifies that a request has been made to the Wiremock server at least once.
    ///
    /// - Parameter mapping: The request mapping to filter on
    /// - Throws: A verfication error if there was no matching request
    public static func verify(requestMapping: RequestMapping) throws {
        let requests = findRequests(requestMapping: requestMapping)
        if requests.count < 1 {
            throw WiremockClientError.verficationError("Did not find a matching request for the \(requestMapping) pattern")
        }
    }
    
    /// Verifies that a request has been made to the Wiremock server a specific number of times.
    ///
    /// - Parameter mapping: The request mapping to filter on
    /// - Throws: A verfication error if the request was not matched the expected number of times
    public static func verify(expectedCount: Int, requestMapping: RequestMapping) throws {
        let requests = findRequests(requestMapping: requestMapping)
        if requests.count != expectedCount  {
            throw WiremockClientError.verficationError("Did not find a matching request for the \(requestMapping) pattern")
        }
    }
    
    /// Looks up all requests matching a given pattern.
    ///
    /// - Parameter requestMapping: The request mapping to filter on
    /// - Returns: An array of LoggedRequest objects or an empty array if there was no match
    public static func findRequests(requestMapping: RequestMapping) -> [LoggedRequest] {
        guard let url = URL(string: "\(baseURL)/__admin/requests/find") else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        request.httpBody = requestMapping.asRequestData()
        let responseData =  makeSynchronousRequest(request: request, errorMessagePrefix: "Error attempting to verify a request")
        var returnRequests: [LoggedRequest] = []
        let decoder = JSONDecoder()
        if let json = responseData {
            if let requests = try? decoder.decode(AllLoggedRequests.self, from: json) {
                returnRequests = requests.requests
            }
        }
        return returnRequests
    }
    
    /// Calls to the server to see if it is up and running.
    /// If there is a mappings element returned, and no error, we should be good.
    ///
    /// - Returns: true if the server is running and ready to interact with
    public static func isServerRunning() -> Bool {
        guard let url = URL(string: "\(baseURL)/__admin/mappings") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.GET.rawValue
        let responseData = makeSynchronousRequest(request: request, errorMessagePrefix: "Received an error from the server")
        if let responseData = responseData, let responseString = String(data: responseData, encoding: .utf8) {
            return responseString.contains("\"mappings\" :")
        }
        return false
    }
    
    /// Persists all stub mappings to the `mappings` directory of the Wiremock server.
    public static func saveAllMappings() {
        postCommandToServer(urlCommand: "__admin/mappings/save", errorMessagePrefix: "Error saving all mappings")
    }
    
    /// Removes all stub mappings and deletes request logs from the Wiremock server.
    public static func reset() {
        postCommandToServer(urlCommand: "__admin/reset", errorMessagePrefix: "Error resetting the server")
    }
    
    /// Resets the state of all scenarios to `start`.
    public static func resetAllScenarios() {
        postCommandToServer(urlCommand: "__admin/scenarios/reset", errorMessagePrefix: "Error resetting all scenarios")
    }
    
    /// Shuts down the Wiremock server.
    public static func shutdownServer()  {
        postCommandToServer(urlCommand: "__admin/shutdown", errorMessagePrefix: "Error shutting down the server")
    }
    
    /// Adds a delay to all responses from the Wiremock server.
    ///
    /// - Parameter delay: The time interval in milliseconds by which to delay all responses
    public static func addGlobalDelay(_ delay: Int) {
        guard let url = URL(string: "\(baseURL)/__admin/settings") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        let data = try? JSONSerialization.data(withJSONObject: ["fixedDelay": delay], options: [.prettyPrinted])
        request.httpBody = data
        makeSynchronousRequest(request: request, errorMessagePrefix: "Error adding global delay")
    }
    
    /// MARK: Private methods
    
    private static func postCommandToServer(urlCommand: String, errorMessagePrefix: String) {
        guard let url = URL(string: "\(baseURL)/\(urlCommand)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        makeSynchronousRequest(request: request, errorMessagePrefix: errorMessagePrefix)
    }
    
    @discardableResult private static func makeSynchronousRequest(request: URLRequest, errorMessagePrefix: String) -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data? = nil
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(errorMessagePrefix): \(error.localizedDescription)")
            } else {
                responseData = data
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return responseData
    }

    
}
