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
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error posting mapping: \(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
    
    public static func updateMapping(uuid: UUID, stubMapping: StubMapping) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/\(uuid.uuidString)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.PUT.rawValue
        request.httpBody = stubMapping.asData()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating mapping: \(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
    
    public static func deleteMapping(uuid: UUID) {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/\(uuid.uuidString)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.DELETE.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting mapping: \(error.localizedDescription)")
                return
            }
        }
        task.resume()
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
                print("Received and error from the server: \(error.localizedDescription)")
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
        postCommandToServer(urlCommand: "__admin/mappings/save", errorMessage: "Error saving all mappings")
    }
    
    public static func reset() {
        postCommandToServer(urlCommand: "__admin/reset", errorMessage: "Error deleting all mappings")
    }
    
    public static func resetAllScenarios() {
        postCommandToServer(urlCommand: "__admin/scenarios/reset", errorMessage: "Error resetting all scenarios")
    }
    
    public static func shutdownServer()  {
        postCommandToServer(urlCommand: "__admin/shutdown", errorMessage: "Error shutting down the server")
    }
    
    /// MARK: Private methods
    
    private static func postCommandToServer(urlCommand: String, errorMessage: String) {
        guard let url = URL(string: "\(baseURL)/\(urlCommand)") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(errorMessage): \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
}
