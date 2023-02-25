import Foundation
import CoreData

typealias BooksListFetchCompletionHandler = (_ fetchedBooksList: [WBook]?) -> Void
typealias VoidCompletionHandler = () -> Void

protocol WBooksServiceProtocol {
    
    func fetchBooks(_ searchTitleString: String?, _ completionBlock: @escaping BooksListFetchCompletionHandler)
    
}

class WBooksService: WBooksServiceProtocol {
    
    private var coreDataService: WCoreDataServiceProtocol?
    
    init(_ coreDataService: WCoreDataServiceProtocol?) {
        self.coreDataService = coreDataService
    }

    //  MARK: - WTextsServiceProtocol -

    func fetchBooks(_ searchTitleString: String?, _ completionBlock: @escaping BooksListFetchCompletionHandler) {
        completionBlock([
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
            WBook(author: "Patanjali", title: "sutras", year: 1983),
            WBook(author: "matsiendra", title: "yoga", year: 1983),
            WBook(author: "tor", title: "hjatha", year: 1983),
        ])
        return
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

            var coredataBooksList: [CDText]?
            do {
                coredataBooksList = try localContext.fetch(fetchRequest) as? [CDText]
            }
            catch _ {
                completionBlock(nil)
                return
            }
            
            completionBlock(self.convertBooksListIntoViewModel(coredataBooksList))
        }
    }
    
    //  MARK: - Routine -

    private func convertBooksListIntoViewModel(_ coreDataBooksList: [CDText]?) -> [WBook]? {
        guard let coreDataBooksList = coreDataBooksList else {
            return nil
        }
        
        var modelsList = [WBook]()
        coreDataBooksList.forEach({ book in
            modelsList.append(WBook(versesList: convertVersesListIntoViewModel(book.versesList),
                                    author: book.author ?? "",
                                    title: book.title ?? "",
                                    year: Int(book.year)))
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
