//
//  WWordsListAssembly.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

class WWordsListAssembly {
    
    static func createModule(coreDataService: WCoreDataServiceProtocol) -> WWordsListView {
        let networkService = WNetworkService()
        let jnanaAPIService = WJnanaAPIService(networkService)
        let booksService = WBooksService(coreDataService,
                                         jnanaAPIService)
        return WWordsListView(wordsService: WWordsService(coreDataService: coreDataService,
                                                          booksService: booksService))
    }
    
}
