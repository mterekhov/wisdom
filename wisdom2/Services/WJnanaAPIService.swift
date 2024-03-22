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


protocol WJnanaAPIServiceProtocol {
    
    func booksList() async -> Result<[String:Any], Error>
    func bookContent(_ bookID: String) async -> Result<[String:Any], Error>

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

    func booksList() async -> Result<[String:Any], Error> {
        let requestString = generateRequestString(requestName: RequestNameBooksListKey)
        let responseResult = await networkService.sendPOSTRequest(host: host, link: "", httpBody: Data(requestString.utf8))
        switch responseResult {
        case .success(let responseData):
            return .success(parseResponse(jsonData: responseData))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func bookContent(_ bookID: String) async -> Result<[String:Any], Error> {
        let requestString = generateRequestString(requestName: RequestNameBookContentKey, parameters: [BookIDKey:bookID])
        let responseResult = await networkService.sendPOSTRequest(host: host, link: "", httpBody: Data(requestString.utf8))
        switch responseResult {
        case .success(let responseData):
            return .success(parseResponse(jsonData: responseData))
        case .failure(let error):
            return .failure(error)
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
