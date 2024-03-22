//
//  WLibraryView.swift
//  wisdom2
//
//  Created by cipher on 13.11.2023.
//

import SwiftUI

struct WLibraryView: View {
    
    let booksService: WBooksServiceProtocol
    let router: WLibraryRouterProtocol
    
    @State private var booksList: [WBook]?
    
    init(booksService: WBooksServiceProtocol, router: WLibraryRouterProtocol) {
        self.booksService = booksService
        self.router = router
    }
        
    var body: some View {
        VStack {
            Text("Books")
                .setFont(.title)
                .padding()
            Spacer()
            if let booksList = booksList {
                List {
                    ForEach(Array(booksList.enumerated()), id: \.offset) { i, book in
                        VStack {
                            NavigationLink(value: i,
                                           label: {
                                Text(booksList[i].sanskrit)
                                    .setFont(.sanskrit)
                            })
                        }
                        .navigationDestination(for: Int.self) { bookIndex in
                            router.showBook(book: booksList[bookIndex])
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.wisdom_rowColor(i))
                    }
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 64)
            }
            else {
                Text("WLibraryView.EmptyLibrary".local)
                    .setFont(.body)
            }
        }
        .navigationTitle(" ")
        .onAppear {
            Task {
                await fetchBooksList()
                await downloadBooksList()
            }
        }
    }
    
    private func fetchBooksList() async {
        let fetchResult = await booksService.fetchBooksList(filterString: nil)
        switch fetchResult {
        case .success(let fetchedBooksList):
            booksList = fetchedBooksList
        case .failure(let error):
            print(error)
        }
    }
    
    private func downloadBooksList() async {
        let downloadResult = await booksService.downloadBooksList()
        switch downloadResult {
        case .success(let downloadedBooksList):
            await booksService.saveBooksList(booksList: downloadedBooksList)
            await fetchBooksList()
        case .failure(let error):
            print(error)
        }
    }
    
}
