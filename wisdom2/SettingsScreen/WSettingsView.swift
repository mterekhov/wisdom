//
//  WSettingsView.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

struct WSettingsView: View {

    let settingsService: WSettingsServiceProtocol
    
    init(settingsService: WSettingsServiceProtocol) {
        self.settingsService = settingsService
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Settings")
                    .background(Color(.yellow))
                    .setFont(.title)
                    .padding()
                Spacer()
            }
            HStack {
                Text("Version \(settingsService.findVersionNumber())")
                    .background(Color(.yellow))
                    .setFont(.body)
                Spacer()
            }
            Spacer()
        }
    }
}
