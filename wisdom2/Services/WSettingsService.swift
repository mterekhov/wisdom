//
//  File.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import Foundation

protocol WSettingsServiceProtocol {

    func findVersionNumber() -> String
    
}

class WSettingsService: WSettingsServiceProtocol {
    
    let bundle: Bundle
    
    init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    func findVersionNumber() -> String {
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
}
