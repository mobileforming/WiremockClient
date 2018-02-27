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
    
    public static func saveAllMappings() {
        guard let url = URL(string: "\(baseURL)/__admin/mappings/save") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saving all mappings: \(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
    
    public static func reset() {
        guard let url = URL(string: "\(baseURL)/__admin/reset") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting all mappings: \(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
    
    public static func resetAllScenarios() {
        guard let url = URL(string: "\(baseURL)/__admin/scenarios/reset") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.POST.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error resetting all scenarios: \(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
}
