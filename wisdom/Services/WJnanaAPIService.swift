//
//  WJnanaAPIService.swift
//  wisdom
//
//  Created by cipher on 01.11.2023.
//

import Foundation

typealias BooksListCompletionHandler = (_ result: Result<[String:Any], Error>) -> Void
typealias VersesListCompletionHandler = (_ result: Result<[String:Any], Error>) -> Void

let PayloadKey = "payload"
let BookIDKey = "book_id"

enum WJnanaAPIServiceError: LocalizedError {
    
    case failedToSendRequest
    
    var errorDescription: String? {
        switch self {
        case .failedToSendRequest:
            return "JnanaAPIService.FailedSendRequest".local
        }
    }
}
protocol WJnanaAPIServiceProtocol {
    
    func booksList(_ completionBlock: @escaping BooksListCompletionHandler)
    func bookContent(_ bookID: String, _ completionBlock: @escaping VersesListCompletionHandler)

}

class WJnanaAPIService: WJnanaAPIServiceProtocol {
    
    private let RequestsListKey = "requests_list"
    private let RequestNameKey = "name"
    private let RequestNameBooksListKey = "books_list"
    private let RequestNameBookContentKey = "book_content"
    private let RequestNameBookSourcesListKey = "books_source"


    private let host = "192.168.1.176"
    
    var networkService: WNetworkServiceProtocol = WNetworkService()
    
    init(_ networkService: WNetworkServiceProtocol) {
        self.networkService = networkService
    }

    //  MARK: - WJnanaAPIServiceProtocol -

    func booksList(_ completionBlock: @escaping BooksListCompletionHandler) {
        let requestString = generateRequestString(requestName: RequestNameBooksListKey)
        if ((networkService.sendPOSTRequest(host: host, link: "", httpBody: Data(requestString.utf8)) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let responseData):
                let json = self.parseResponse(jsonData: responseData)
                completionBlock(.success(json))
                case .failure(let error):
                completionBlock(.failure(error))
            }
        }) == false) {
            completionBlock(.failure(WJnanaAPIServiceError.failedToSendRequest))
        }
    }
    
    func bookContent(_ bookID: String, _ completionBlock: @escaping VersesListCompletionHandler) {
        let requestString = generateRequestString(requestName: RequestNameBookContentKey, parameters: [BookIDKey:bookID])
        if ((networkService.sendPOSTRequest(host: host, link: "", httpBody: Data(requestString.utf8)) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let responseData):
                let json = self.parseResponse(jsonData: responseData)
                completionBlock(.success(json))
                case .failure(let error):
                completionBlock(.failure(error))
            }
        }) == false) {
            completionBlock(.failure(WJnanaAPIServiceError.failedToSendRequest))
        }
    }
    
    //  MARK: - Routine -

    private func parseResponse(jsonData: Data?) -> [String:Any] {
        var jsonDict = [String:Any]()
        guard let jsonData = jsonData else {
            return jsonDict
        }
        
        do {
            jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] ?? [String:Any]()
        }
        catch _ {
            return jsonDict
        }
        
        return jsonDict

    }

    private func generateRequestString(requestName: String, parameters: [String:String] = [String:String]()) -> String {
        var requestString = "{\"\(RequestsListKey)\":["
        requestString += "{\"\(RequestNameKey)\":\"\(requestName)\",\"\(PayloadKey)\":{"

        parameters.forEach { (key: String, value: String) in
            requestString += "\"\(key)\":\"\(value)\","
        }
        if !parameters.isEmpty {
            requestString.removeLast()
        }
        
        requestString += "}}]}"
        
        return requestString
    }
    
}
