//
//  WiremockClientNetworkService.swift
//  WiremockClientPackageDescription
//
//  Created by Ted Rothrock on 2/12/21.
//

import Foundation

protocol SynchronousURLSession {
    func executeSynchronousRequest(_ request: URLRequest) -> Result<Data?, Error>
}

extension URLSession: SynchronousURLSession {
    func executeSynchronousRequest(_ request: URLRequest) -> Result<Data?, Error> {
        var data: Data?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let task = dataTask(with: request) { responseData, _, responseError in
            data = responseData
            error = responseError
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let error = error {
            return .failure(error)
        } else {
            return .success(data)
        }
    }
    
}

struct WiremockClientNetworkService: NetworkService {
    
    @DebugOverridable
    var urlSession: SynchronousURLSession = URLSession.shared
    
    func makeSynchronousRequest(with endpoint: Endpoint) throws {
        guard let urlRequest = endpoint.urlRequest else {
            throw WiremockClientError.invalidUrl
        }
        
        let result = urlSession.executeSynchronousRequest(urlRequest)
        
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func makeSynchronousRequest<T: Decodable>(with endpoint: Endpoint) throws -> T {
        guard let urlRequest = endpoint.urlRequest else {
            throw WiremockClientError.invalidUrl
        }
        
        let result = urlSession.executeSynchronousRequest(urlRequest)
        
        switch result {
        case .success(let data):
            guard let data = data else {
                throw WiremockClientError.decodingError
            }
            return try JSONDecoder().decode(T.self, from: data)
        case .failure(let error):
            throw error
        }
    }
}
