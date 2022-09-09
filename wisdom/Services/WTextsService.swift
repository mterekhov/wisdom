//
//  WTextsService.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import Foundation
import CoreData

typealias TextsListFetchCompletionHandler = (_ textsList: [WText]?) -> Void
typealias VoidCompletionHandler = () -> Void

protocol WTextsServiceProtocol {
    
    func fetchTexts(_ searchTitleString: String?, _ completionBlock: @escaping TextsListFetchCompletionHandler)
    
}

class WTextsService: WTextsServiceProtocol {
    
    private var coreDataService: WCoreDataServiceProtocol?
    
    init(_ coreDataService: WCoreDataServiceProtocol?) {
        self.coreDataService = coreDataService
    }

    //  MARK: - WTextsServiceProtocol -

    func fetchTexts(_ searchTitleString: String?, _ completionBlock: @escaping TextsListFetchCompletionHandler) {
        guard let coreDataService = coreDataService else {
            completionBlock(nil)
            return
        }

        coreDataService.asyncExecute { [weak self] localContext in
            guard let self = self else {
                return
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CDText.entity().name ?? "")
            if let searchTitleString = searchTitleString,
               !searchTitleString.isEmpty {
                fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTitleString)
            }

            var coredataTextsList: [CDText]?
            do {
                coredataTextsList = try localContext.fetch(fetchRequest) as? [CDText]
            }
            catch _ {
                completionBlock(nil)
                return
            }
            
            completionBlock(self.convertTextsListIntoViewModel(coredataTextsList))
        }
    }
    
    //  MARK: - Routine -

    private func convertTextsListIntoViewModel(_ coreDataTextsList: [CDText]?) -> [WText]? {
        guard let coreDataTextsList = coreDataTextsList else {
            return nil
        }
        
        var modelsList = [WText]()
        coreDataTextsList.forEach({ text in
            modelsList.append(WText(versesList: convertVersesListIntoViewModel(text.versesList),
                                    author: text.author ?? "",
                                    title: text.title ?? "",
                                    year: Int(text.year)))
        })
        
        return modelsList
    }
    
    private func convertVersesListIntoViewModel(_ coreDataVersesList: NSOrderedSet?) -> [WVerse]? {
        guard let coreDataVersesList = coreDataVersesList else {
            return nil
        }

        var modelsList = [WVerse]()
        for verse in coreDataVersesList {
            guard let verse = verse as? CDVerse else {
                continue
            }

            modelsList.append(WVerse(sanskrit: verse.sanskrit ?? "",
                                     english: verse.english ?? "",
                                     iast: verse.iast ?? ""))
        }
        
        return modelsList
    }
    
}
