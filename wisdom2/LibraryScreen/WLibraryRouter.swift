//
//  WLibraryRouter.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

protocol WLibraryRouterProtocol {

    func showBook(book: WBook) -> WBookView
    
}

class WLibraryRouter: WLibraryRouterProtocol {

    let coreDataService: WCoreDataServiceProtocol
    
    init(coreDataService: WCoreDataServiceProtocol) {
        self.coreDataService = coreDataService
    }
    
    func showBook(book: WBook) -> WBookView {
        return WBookAssembly.createModule(book: book,
                                          coreDataService: coreDataService)
    }
    
}
