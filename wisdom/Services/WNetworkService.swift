//
//  WNetworkService.swift
//  wisdom
//
//  Created by cipher on 01.11.2023.
//

import Foundation

typealias NetworkCompletionHandler = (_ result: Result<Data?, Error>) -> Void

enum WNetworkServiceError: LocalizedError {
    
    case incorrectResponse
    case serverSideError
    case unknownServerError
    
    var errorDescription: String? {
        switch self {
        case .incorrectResponse:
            return "NetworkServiceError.IncorrectResponse".local
        case .serverSideError:
            return "NetworkServiceError.ServerSideError".local
        case .unknownServerError:
            return "NetworkServiceError.UnknownServerError".local
            
        }
    }
}

protocol WNetworkServiceProtocol {
    
    func sendPOSTRequest(host: String, link: String, httpBody: Data?, completionBlock: NetworkCompletionHandler?) -> Bool

}

class WNetworkService: WNetworkServiceProtocol {
    
    private let requestTimeout: TimeInterval = 60
    
    //  MARK: - WNetworkServiceProtocol -

    func sendPOSTRequest(host: String, link: String, httpBody: Data?, completionBlock: NetworkCompletionHandler?) -> Bool {
        //  create URL
        guard let url = URL(string: "http://" + host + "/" + link) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout
        
        //  create session
        let session = URLSession(configuration: configuration,
                                 delegate: nil,
                                 delegateQueue: nil)

        let task = session.dataTask(with: request) { data, response, error in
            guard let completionBlock = completionBlock else {
                session.invalidateAndCancel()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionBlock(.failure(WNetworkServiceError.incorrectResponse))
                session.invalidateAndCancel()
                return
            }

            if error != nil || httpResponse.statusCode !=  200 {
                if httpResponse.statusCode != 200 {
                    completionBlock(.failure(WNetworkServiceError.serverSideError))
                }
                else {
                    if let error = error {
                        completionBlock(.failure(error))
                    }
                    else {
                        completionBlock(.failure(WNetworkServiceError.unknownServerError))
                    }
                }
                session.invalidateAndCancel()
                
                return
            }

            completionBlock(.success(data))
            session.invalidateAndCancel()
        }
        
        task.resume()
        
        return true
    }
    
}
