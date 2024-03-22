//
//  wisdom2App.swift
//  wisdom2
//
//  Created by cipher on 13.11.2023.
//

import SwiftUI

@main
struct wisdom2App: App {
    
    private let coreDataService: WCoreDataServiceProtocol = WCoreDataService()

    var body: some Scene {
        WindowGroup {
            WMenuAssembly.createModule(coreDataService: coreDataService)
        }
    }
    
}
