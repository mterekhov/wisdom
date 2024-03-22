//
//  WEditWordView.swift
//  wisdom2
//
//  Created by cipher on 02.12.2023.
//

import SwiftUI

extension AnyTransition {
    
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
}

struct WEditWordView: View {
    
    @State private var showSanskrit = false
    @State private var showEnglish = false
    @State private var showIAST = false
    @State private var showNotes = false
    @State var word = WWord(uuid: UUID().uuidString)
    let router: WEditWordRouterProtocol
    
    init(router: WEditWordRouterProtocol, word: WWord) {
        self.router = router
        self.word = word
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                WEditableText(text: $word.sanskrit, title: "Sanskrit", extended: $showSanskrit)
                    .border(Color.cyan, width: 4)
                    .background(Color.green)
//                WEditableText(text: word.$iast, title: "IAST", extended: $showIAST)
//                WEditableText(text: word.$english, title: "Translation", extended: $showEnglish)
//                WEditableText(text: word.$notes, title: "Notes", extended: $showNotes)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        router.closeScreen()
                    }
                    .background(Color.gray)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        router.closeScreen()
                    }
                    .background(Color.gray)
                }
            }
        }
        .setFont(.body)
        .background(Color.cyan)
    }
    
}

struct WEditableText: View {
    
    @Binding private var extended: Bool
    @Binding private var text: String
    private let title: String

    init(text: Binding<String>, title: String, extended: Binding<Bool>) {
        _extended = extended
        _text = text
        
        self.title = title
    }
    
    var body: some View {
        VStack(alignment:.leading, spacing:0) {
            HStack {
                Spacer()
                Text(title)
                    .onTapGesture {
                        withAnimation {
                            extended.toggle()
                        }
                    }
                    .lineLimit(1)
            }
            
            if extended {
                VStack {
                    TextEditor(text: $text)
                        .transition(.moveAndFade)
                }
            }
            else {
                Text(text)
                    .lineLimit(3)
            }
            Spacer()
        }
        .padding(10)
    }
    
}
