//
//  WEditWordRouter.swift
//  wisdom2
//
//  Created by cipher on 02.12.2023.
//

import SwiftUI

enum WEditWordRoutesList: String {
    
    case editSanskrit
    case editIAST
    case editTranslation
    case editNotes

}

protocol WEditWordRouterProtocol {
 
    func closeScreen()

}

class WEditWordRouter: WEditWordRouterProtocol {
    
    @Binding private var isPresented: Bool
    
    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    func closeScreen() {
        isPresented = false
    }
    
}
