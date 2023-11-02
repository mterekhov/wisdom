//
//  WNetworkService.swift
//  wisdom
//
//  Created by cipher on 01.11.2023.
//

import Foundation

enum WNetworkServiceError: LocalizedError {
    
    case incorrectResponse
    case serverSideError
    case unknownServerError
    case brokenLink
    
    var errorDescription: String? {
        switch self {
        case .incorrectResponse:
            return "NetworkServiceError.IncorrectResponse".local
        case .serverSideError:
            return "NetworkServiceError.ServerSideError".local
        case .unknownServerError:
            return "NetworkServiceError.UnknownServerError".local
        case .brokenLink:
            return "NetworkServiceError.BrokenLink".local

        }
    }
}

protocol WNetworkServiceProtocol {
    
    func sendPOSTRequest(host: String, link: String, httpBody: Data?) async -> Result<Data?, Error>

}

class WNetworkService: WNetworkServiceProtocol {
    
    private let requestTimeout: TimeInterval = 60
    
    //  MARK: - WNetworkServiceProtocol -

    func sendPOSTRequest(host: String, link: String, httpBody: Data?) async -> Result<Data?, Error> {
        //  create URL
        guard let url = URL(string: "http://" + host + "/" + link) else {
            return .failure(WNetworkServiceError.brokenLink)
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
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(WNetworkServiceError.incorrectResponse)
            }
            
            if httpResponse.statusCode !=  200 {
                return .failure(WNetworkServiceError.serverSideError)
            }
            
            return .success(data)
        }
        catch {
            return .failure(error)
        }
    }
    
}
