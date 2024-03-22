//
//  WWord.swift
//  wisdom2
//
//  Created by cipher on 01.12.2023.
//

import Foundation

class WWord: ObservableObject {

    let uuid: String
    @Published var sanskrit = ""
    @Published var english = ""
    @Published var iast = ""
    @Published var notes = ""

    init(uuid: String) {
        self.uuid = uuid
    }
    
}
