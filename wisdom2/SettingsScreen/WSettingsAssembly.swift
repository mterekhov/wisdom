//
//  WSettingsAssembly.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

class WSettingsAssembly {
    
    static func createModule(bundle: Bundle) -> WSettingsView {
        let settingsService = WSettingsService(bundle: bundle)
        return WSettingsView(settingsService: settingsService)
    }
    
}
