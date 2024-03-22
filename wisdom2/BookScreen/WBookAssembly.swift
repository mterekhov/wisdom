//
//  WBookAssembly.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

class WBookAssembly {

    static func createModule(book: WBook, coreDataService: WCoreDataServiceProtocol) -> WBookView {
        let networkService:WNetworkServiceProtocol = WNetworkService()
        let jnanaAPIService: WJnanaAPIServiceProtocol = WJnanaAPIService(networkService)
        return WBookView(bookUUID: book.uuid,
                         booksService: WBooksService(coreDataService, jnanaAPIService),
                         router: WBookRouter())
    }
    
}
