//
//  WBookView.swift
//  wisdom2
//
//  Created by cipher on 13.11.2023.
//

import SwiftUI

struct WBookView: View {

    @State private var verseIndex: Int = 0
    @State private var book: WBook?
    @State private var isPresentedWordScreen = false
    
    let bookUUID: String
    let booksService: WBooksServiceProtocol
    let router: WBookRouterProtocol

    init(bookUUID: String, booksService: WBooksServiceProtocol, router: WBookRouterProtocol) {
        self.bookUUID = bookUUID
        self.booksService = booksService
        self.router = router
    }
    
    private func versesCount() -> Int {
        guard let versesList = book?.versesList else {
            return 0
        }
        
        return versesList.count
    }
    
    private func currentVerse(_ index: Int) -> WVerse? {
        if index >= (book?.versesList?.count ?? 0) {
            return book?.versesList?.last
        }
        
        return book?.versesList?[verseIndex]
    }
    
    private func incVerseIndex() {
        if verseIndex + 1 >= book?.versesList?.count ?? 0 {
            return
        }
        
        verseIndex += 1
    }
    
    private func decVerseIndex() {
        if verseIndex - 1 < 0 {
            return
        }
        
        verseIndex -= 1
    }
    
    var body: some View {
        if (versesCount() > 0) {
            VStack {
                HStack {
                    Spacer()
                    Button("Add") {
                        isPresentedWordScreen = true
                    }
                }
                Text(book?.sanskrit ?? "")
                    .setFont(.sanskrit)
                    .padding()
                Text("\(verseIndex + 1)/\(book?.versesList?.count ?? 0)")
                    .padding()
                Spacer()
                Text("Sanskrit")
                HStack {
                    Text(currentVerse(verseIndex)?.sanskrit ?? "")
                        .setFont(.sanskrit)
                    Spacer()
                }
                Spacer()
                Text("IAST")
                HStack {
                    Text(currentVerse(verseIndex)?.iast ?? "")
                    Spacer()
                }
                Spacer()
                Text("English")
                HStack {
                    Text(currentVerse(verseIndex)?.english ?? "")
                    Spacer()
                }
                Spacer()
                HStack {
                    if verseIndex != 0 {
                        Button(action: {
                            decVerseIndex()
                        }, label: {
                            Text("Previous")
                        })
                        .padding()
                    }
                    Spacer()
                    if verseIndex < book?.versesList?.count ?? 0 {
                        Button(action: {
                            incVerseIndex()
                        }, label: {
                            Text("Next")
                        })
                        .padding()
                    }

                }
            }
            .setFont(.body)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .fullScreenCover(isPresented: $isPresentedWordScreen, content: {
                router.showNewWordScreen(verse: book?.versesList?[verseIndex] ?? WVerse(sanskrit: "empty", english: "empty", iast: "empty", index: 0),
                                         isPresented: $isPresentedWordScreen)
            })
            .onAppear {
                Task {
                    await refreshVersesList()
                    let downloadVersesListResult = await booksService.downloadVersesList(bookUUID: bookUUID)
                    switch downloadVersesListResult {
                    case .success(let versesList):
                        await booksService.saveVersesList(bookUUID: bookUUID, versesList: versesList)
                        await refreshVersesList()

                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        else {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("There are no verses in book")
                    Spacer()
                }
                Spacer()
            }
            .onAppear {
                Task {
                    let downloadVersesListResult = await booksService.downloadVersesList(bookUUID: bookUUID)
                    switch downloadVersesListResult {
                    case .success(let versesList):
                        await booksService.saveVersesList(bookUUID: bookUUID, versesList: versesList)
                        await refreshVersesList()

                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func refreshVersesList() async {
        guard let bookFound = await booksService.fetchBook(bookUUID: bookUUID) else {
            return
        }
        
        book = bookFound
    }
    
}
