//
//  WiremockClient.swift
//  NewWiremockClient
//
//  Created by Ted Rothrock on 6/24/17.
//  Copyright © 2017 Ted Rothrock. All rights reserved.
//

import Foundation

public struct WiremockClient {
    
    public static var baseURL = "http://localhost:8080"
    
    public static func postMapping(stubMapping: StubMapping) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        request.httpBody = stubMapping.asData()
        makeSynchronousRequest(request: request, errorMessagePrefix: "Error posting mapping")
    }
    
    public static func updateMapping(uuid: UUID, stubMapping: StubMapping) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/\(uuid.uuidString)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.PUT.rawValue
        request.httpBody = stubMapping.asData()
        makeSynchronousRequest(request: request, errorMessagePrefix: "Error updating mapping")
    }
    
    public static func deleteMapping(uuid: UUID) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/\(uuid.uuidString)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.DELETE.rawValue
        makeSynchronousRequest(request: request, errorMessagePrefix: "Error deleting mapping")
    }
    
    
    /// Verify that a request has been made to the wiremock server.
    ///
    /// - Parameter mapping: the request mapping to filter against
    /// - Returns: the first matching request or nil if nothing was found
    public static func verify(requestMapping: RequestMapping) -> String? {
        guard let url = URL(string: "\(baseURL)/__admin/requests/find") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        request.httpBody = requestMapping.asRequestData()
        let semaphore = DispatchSemaphore(value: 0)
        var responseString = ""
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error attempting to verify a request: \(error.localizedDescription)")
            } else {
                responseString = String(data: data!, encoding: .utf8)!
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return responseString
    }
    
    /// Synchrounous call to the server to see if it is up and running
    /// If there is a mappings element returned, and no error, we should be good.
    public static func isServerRunning() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = URL(string: "\(baseURL)/__admin/mappings") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.GET.rawValue
        var isRunning = false;
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Received an error from the server: \(error.localizedDescription)")
            } else {
                if let data = data {
                    isRunning = String(data: data, encoding: .utf8)!.contains("\"mappings\" :")
                }
            }
            semaphore.signal();
        }
        task.resume()
        semaphore.wait()
        return isRunning
    }
    
    public static func saveAllMappings() {
        postCommandToServer(urlCommand: "__admin/mappings/save", errorMessagePrefix: "Error saving all mappings")
    }
    
    public static func reset() {
        postCommandToServer(urlCommand: "__admin/reset", errorMessagePrefix: "Error deleting all mappings")
    }
    
    public static func resetAllScenarios() {
        postCommandToServer(urlCommand: "__admin/scenarios/reset", errorMessagePrefix: "Error resetting all scenarios")
    }
    
    public static func shutdownServer()  {
        postCommandToServer(urlCommand: "__admin/shutdown", errorMessagePrefix: "Error shutting down the server")
    }
    
    /// MARK: Private methods
    
    private static func postCommandToServer(urlCommand: String, errorMessagePrefix: String) {
        guard let url = URL(string: "\(baseURL)/\(urlCommand)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        makeSynchronousRequest(request: request, errorMessagePrefix: errorMessagePrefix)
    }
    
    private static func makeSynchronousRequest(request: URLRequest, errorMessagePrefix: String) {
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(errorMessagePrefix): \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
}
