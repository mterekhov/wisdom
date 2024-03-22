//
//  WEditWordAssembly.swift
//  wisdom2
//
//  Created by cipher on 02.12.2023.
//

import SwiftUI

class WEditWordAssembly {
    
    static func createModule(word: WWord, isPresented: Binding<Bool>) -> WEditWordView {
        let router = WEditWordRouter(isPresented: isPresented)
        let view = WEditWordView(router: router, word: word)
        view.word = word
        return view
    }
        
}
