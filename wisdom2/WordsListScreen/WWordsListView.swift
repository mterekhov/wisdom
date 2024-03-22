//
//  WWordsListView.swift
//  wisdom2
//
//  Created by cipher on 24.11.2023.
//

import SwiftUI

struct WWordsListView: View {
    
    @State private var wordsList: [WWord]?
    
    let wordsService: WWordsServiceProtocol
    
    init(wordsService: WWordsServiceProtocol) {
        self.wordsService = wordsService
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Add") {
                }
            }
            Spacer()
            if let wordsList = wordsList {
                List {
                    ForEach(Array(wordsList.enumerated()), id: \.offset) { i, word in
                        VStack {
                            NavigationLink(value: word.uuid,
                                           label: {
                                Text(wordsList[i].sanskrit)
                                    .setFont(.sanskrit)
                            })
                        }
                        .navigationDestination(for: Int.self) { wordUUID in
                            Text("word \(wordUUID) selected")
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.wisdom_rowColor(i))
                    }
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 64)
                .onAppear {
                    Task {
                        let fetchWordsListResult = await wordsService.wordsList()
                        switch fetchWordsListResult {
                        case .success(let fetchedWordsList):
                            self.wordsList = fetchedWordsList
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
            else {
                Text("WWordsListView.NoWords".local)
                    .setFont(.body)
            }
            Spacer()
        }
    }
}
