//
//  WBookRouter.swift
//  wisdom2
//
//  Created by cipher on 02.12.2023.
//

import SwiftUI

protocol WBookRouterProtocol {

    func showNewWordScreen(verse: WVerse, isPresented: Binding<Bool>) -> WEditWordView
    
}

class WBookRouter: WBookRouterProtocol {
    
    func showNewWordScreen(verse: WVerse, isPresented: Binding<Bool>) -> WEditWordView {
        let word = WWord(uuid: UUID().uuidString)
        word.sanskrit = verse.sanskrit
        word.iast = verse.iast
        word.english = verse.english
        return WEditWordAssembly.createModule(word: word, isPresented: isPresented)
    }
    
}
