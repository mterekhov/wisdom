//
//  WMenuRouter.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

enum WLibraryNavigation: String {
    case library
    case book
}

enum WSearchNavigation: String {
    case results
}

enum WSettingsNavigation: String {
    case settings
}

enum WWordsListNavigation: String {
    case wordsList
}

protocol WMenuRouterProtocol {
    
}

class WMenuRouter: WMenuRouterProtocol {
    
    @State var libraryNavigationStack: [WLibraryNavigation] = []
    @State var searchNavigationStack: [WSearchNavigation] = []
    @State var settingsNavigationStack: [WSettingsNavigation] = []
    @State var wordsListNavigationStack: [WWordsListNavigation] = []
    
    let coreDataService: WCoreDataServiceProtocol
    
    init(coreDataService: WCoreDataServiceProtocol) {
        self.coreDataService = coreDataService
    }
    
}
