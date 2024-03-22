//
//  WMenuAssembly.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

class WMenuAssembly {
    
    static func createModule(coreDataService: WCoreDataServiceProtocol) -> WMenuView {
        let router = WMenuRouter(coreDataService: coreDataService)
        let libraryView = WLibraryAssembly.createModule(coreDataService: coreDataService)
        let settingsView = WSettingsAssembly.createModule(bundle: Bundle.main)
        let searchView = WSearchAssembly.createModule()
        let wordsListView = WWordsListAssembly.createModule(coreDataService: coreDataService)
        
        let menuView = WMenuView(coreDataService: coreDataService,
                                 router: router,
                                 libraryView: libraryView,
                                 settingsView: settingsView,
                                 searchView: searchView,
                                 wordsListView: wordsListView)
        return menuView
    }
    
}
