//
//  WWordsService.swift
//  wisdom2
//
//  Created by cipher on 01.12.2023.
//

import Foundation
import CoreData

enum WWordsServiceError: String, LocalizedError {
    
    case verseNotFound = "WordsServiceError.VerseNotFound"
    
    var localizedDescription: String { return self.rawValue.local }
    
}

protocol WWordsServiceProtocol {
    
    func wordsList() async -> Result<[WWord], WWordsServiceError>
    func saveWord(word: WWord, bookUUID: String, verseIndex: Int) async -> Result<Bool, WWordsServiceError>
    
}

class WWordsService: WWordsServiceProtocol {
    
    private let coreDataService: WCoreDataServiceProtocol
    private let booksService: WBooksServiceProtocol
    
    init(coreDataService: WCoreDataServiceProtocol, booksService: WBooksServiceProtocol) {
        self.coreDataService = coreDataService
        self.booksService = booksService
    }
    
    //  MARK: - WWordsServiceProtocol -
    
    func wordsList() async -> Result<[WWord], WWordsServiceError> {
        let localContext = coreDataService.newLocalContext()
        var result: Result<[WWord], WWordsServiceError> = .success([])
        
        await localContext.perform {
            do {
                let coredataWordsList = try localContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: CDWord.entity().name ?? "")) as? [CDWord]
                result = .success(self.convertWordsListIntoViewModel(coredataWordsList))
            }
            catch (_) {
            }
        }
        
        return result
    }
    
    func saveWord(word: WWord, bookUUID: String, verseIndex: Int) async -> Result<Bool, WWordsServiceError> {
        let localContext = coreDataService.newLocalContext()
        var result: Result<Bool, WWordsServiceError> = .success(true)
        await localContext.perform {
            let coredataWord = CDWord(context: localContext)
            coredataWord.sanskrit = word.sanskrit
            coredataWord.iast = word.iast
            coredataWord.english = word.english
            coredataWord.notes = word.notes
            coredataWord.uuid = word.uuid
            
            guard let coredataVerse = self.booksService.fetchVerse(bookUUID: bookUUID,
                                                                   verseIndex: verseIndex,
                                                                   localContext: localContext) else {
                result = .failure(WWordsServiceError.verseNotFound)
                return
            }
            coredataVerse.addToWordsList(coredataWord)
            localContext.wisdom_saveContext()
        }
        
        return result
    }
    
    //  MARK: - Routine -
    
    private func convertWordsListIntoViewModel(_ coredataWordsList: [CDWord]?) -> [WWord] {
        var modelsList = [WWord]()
        
        guard let coredataWordsList = coredataWordsList else {
            return modelsList
        }
        
        coredataWordsList.forEach { coredataWord in
            var newWord = WWord(uuid: UUID().uuidString)
            newWord.sanskrit = coredataWord.sanskrit ?? ""
            newWord.english = coredataWord.english ?? ""
            newWord.iast = coredataWord.iast ?? ""
            newWord.notes = coredataWord.notes ?? ""
            modelsList.append(newWord)
        }
        
        return modelsList
    }
    
}
