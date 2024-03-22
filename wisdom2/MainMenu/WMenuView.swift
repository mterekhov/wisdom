//
//  WMenuView.swift
//  wisdom2
//
//  Created by cipher on 13.11.2023.
//

import SwiftUI

struct WMenuView: View {
        
    let router: WMenuRouter

    let coreDataService: WCoreDataServiceProtocol
    let libraryView: WLibraryView
    let settingsView: WSettingsView
    let searchView: WSearchView
    let wordsListView: WWordsListView

    init(coreDataService: WCoreDataServiceProtocol,
         router: WMenuRouter,
         libraryView: WLibraryView,
         settingsView: WSettingsView,
         searchView: WSearchView,
         wordsListView: WWordsListView) {
        self.coreDataService = coreDataService
        self.router = router
        self.libraryView = libraryView
        self.settingsView = settingsView
        self.wordsListView = wordsListView
        self.searchView = searchView
    }
    
    var body: some View {
        TabView {
            NavigationStack(root: {
                                libraryView
                            })
            .tabItem { Text("LIBRARY") }
            
            searchView
                .tabItem { Text("SEARCH") }
            
            wordsListView
                .tabItem { Text("WORDS") }
            
            settingsView
                .tabItem { Text("SETTINGS") }
        }
    }
    
}
