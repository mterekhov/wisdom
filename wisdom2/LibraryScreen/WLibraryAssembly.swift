//
//  WLibraryAssembly.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

class WLibraryAssembly {
    
    static func createModule(coreDataService: WCoreDataServiceProtocol) -> WLibraryView {
        let networkService = WNetworkService()
        let jnanaAPIService = WJnanaAPIService(networkService)
        let booksService = WBooksService(coreDataService,
                                         jnanaAPIService)
        return WLibraryView(booksService: booksService, 
                            router: WLibraryRouter(coreDataService: coreDataService))
    }
    
}
