import Foundation
import CoreData

enum WBooksServiceError: LocalizedError {
    
    case failedToSendRequest
    case coreDataError
    
    var errorDescription: String? {
        switch self {
        case .failedToSendRequest:
            return "BookServiceError.FailedSendRequest".local
        case .coreDataError:
            return "BookServiceError.CoreDataError".local
        }
    }
}

typealias BooksListFetchCompletionHandler = (_ fetchedBooksList: Result<[WBook], Error>) -> Void
typealias BooksListDownloadCompletionHandler = (_ jsonBooksList: Result<[WBook], Error>) -> Void
typealias VersesListDownloadCompletionHandler = (_ jsonVersesList: Result<[WVerse], Error>) -> Void
typealias VoidCompletionHandler = () -> Void

protocol WBooksServiceProtocol {
    
    func fetchBooksList(_ searchTitleString: String?, _ completionBlock: @escaping BooksListFetchCompletionHandler)
    func fetchVerses(_ bookID: String, _ completionBlock: @escaping BooksListFetchCompletionHandler)
    func saveBooksList(_ booksList: [WBook], _ completionHandler: @escaping VoidCompletionHandler)
    func saveVersesList(_ versesList: [WVerse], _ completionHandler: @escaping VoidCompletionHandler)
    func downloadBooksList(_ completionBlock: @escaping BooksListDownloadCompletionHandler)
    
    func downloadVersesList(_ bookID: String, _ completionBlock: @escaping VersesListDownloadCompletionHandler)

}

class WBooksService: WBooksServiceProtocol {
    
    private let ResponsesListKey = "responses_list"
    private let SanskritKey = "sanskrit"
    private let EnglishKey = "english"
    private let IASTKey = "iast"
    private let IndexKey = "index"
    private let UUIDKey = "uuid"

    var coreDataService: WCoreDataServiceProtocol?
    var jnanaAPIService: WJnanaAPIServiceProtocol

    init(_ coreDataService: WCoreDataServiceProtocol?, _ jnanaAPIService: WJnanaAPIServiceProtocol) {
        self.coreDataService = coreDataService
        self.jnanaAPIService = jnanaAPIService
    }

    //  MARK: - WBooksServiceProtocol -

    func downloadVersesList(_ bookID: String, _ completionBlock: @escaping VersesListDownloadCompletionHandler) {
        jnanaAPIService.booksList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let versesListJSON):
                completionBlock(.success(self.parseJSONVersesList(json: versesListJSON)))
            case .failure(let error):
                completionBlock(.failure(error))
                break;
            }
        }
    }

    func fetchBooksList(_ searchTitleString: String?, _ completionBlock: @escaping BooksListFetchCompletionHandler) {
        if let searchTitleString = searchTitleString {
            fetchBook([EnglishKey: searchTitleString], completionBlock)
        }
        else {
            fetchBook(nil, completionBlock)
        }
    }

    func fetchVerses(_ bookID: String, _ completionBlock: @escaping BooksListFetchCompletionHandler) {
        fetchBook([UUIDKey: bookID], completionBlock)
    }

    func saveVersesList(_ versesList: [WVerse], _ completionHandler: @escaping VoidCompletionHandler) {
    }

    func saveBooksList(_ booksList: [WBook], _ completionHandler: @escaping VoidCompletionHandler) {
        guard let coreDataService = coreDataService else {
            completionHandler()
            return
        }
        
        coreDataService.asyncExecute { [weak self] localContext in
            guard let self = self else { return }
            booksList.forEach { book in
                switch self.fetchBook([self.UUIDKey:book.uuid], localContext) {
                case .success(let checkedBooksList):
                    if checkedBooksList.isEmpty {
                        let newBook = CDBook(context: localContext)
                        newBook.sanskrit = book.sanskrit
                        newBook.iast = book.iast
                        newBook.english = book.english
                        newBook.uuid = book.uuid
                        localContext.wisdom_saveContext()
                    }
                case .failure(_):
                    break
                }
            }
            
            completionHandler()
        }
    }
    
    func downloadBooksList(_ completionBlock: @escaping BooksListDownloadCompletionHandler) {
        jnanaAPIService.booksList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let booksJSON):
                completionBlock(.success(self.parseJSONBook(json: booksJSON)))
            case .failure(let error):
                completionBlock(.failure(error))
                break;
            }
        }
    }
    
    //  MARK: - Routine -

    private func fetchBook(_ search: [String:String]?, _ completionBlock: @escaping BooksListFetchCompletionHandler) {
        guard let coreDataService = coreDataService else {
            completionBlock(.failure(WBooksServiceError.coreDataError))
            return
        }

        coreDataService.asyncExecute { [weak self] localContext in
            guard let self = self else {
                return
            }
            
            completionBlock(self.fetchBook(search, localContext))
        }
    }

    private func fetchBook(_ search: [String:String]?, _ localContext: NSManagedObjectContext) -> Result<[WBook], Error>{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CDBook.entity().name ?? "")
        if let search = search {
            var predicateString = ""
            search.forEach { (key: String, value: String) in
                predicateString += "(\(key) CONTAINS[CD] '\(value)') AND "
            }
            predicateString.removeLast(5)
            fetchRequest.predicate = NSPredicate(format: predicateString)
        }

        do {
            guard let coredataBooksList = try localContext.fetch(fetchRequest) as? [CDBook] else {
                return .failure(WBooksServiceError.coreDataError)
            }
            return .success(self.convertBooksListIntoViewModel(coredataBooksList))
        }
        catch _ {
            return .failure(WBooksServiceError.coreDataError)
        }
    }
    
    private func parseJSONBook(json: [String:Any]) -> [WBook] {
        var booksList =  [WBook]()
        guard let responsesList = json[ResponsesListKey] as? [[String:Any]] else { return booksList };
        guard let booksListResponse = responsesList.first else { return booksList }
        guard let payload = booksListResponse[PayloadKey] as? [[String:Any]] else { return booksList };
        payload.forEach { bookJSON in
            let newBook = WBook(sanskrit: (bookJSON[SanskritKey] as? String) ?? "",
                                english: (bookJSON[EnglishKey] as? String) ?? "",
                                iast: (bookJSON[IASTKey] as? String) ?? "",
                                uuid: (bookJSON[BookIDKey] as? String) ?? "")
            booksList.append(newBook)
        }
        
        return booksList
    }
    
    private func parseJSONVersesList(json: [String:Any]) -> [WVerse] {
        var versesList =  [WVerse]()
        guard let responsesList = json[ResponsesListKey] as? [[String:Any]] else { return versesList };
        guard let versesListResponse = responsesList.first else { return versesList }
        guard let payload = versesListResponse[PayloadKey] as? [[String:Any]] else { return versesList };
        payload.forEach { verseJSON in
            let newVerse = WVerse(sanskrit: (verseJSON[SanskritKey] as? String) ?? "",
                                  english: (verseJSON[EnglishKey] as? String) ?? "",
                                  iast: (verseJSON[IASTKey] as? String) ?? "",
                                  index: (verseJSON[IndexKey] as? Int) ?? 0)
            versesList.append(newVerse)
        }
        
        return versesList
    }
    
    private func convertBooksListIntoViewModel(_ coreDataBooksList: [CDBook]?) -> [WBook] {
        var modelsList = [WBook]()

        guard let coreDataBooksList = coreDataBooksList else {
            return modelsList
        }
        
        coreDataBooksList.forEach({ book in
            modelsList.append(WBook(sanskrit: book.sanskrit ?? "",
                                    english: book.english ?? "",
                                    iast: book.iast ?? "",
                                    uuid: book.uuid ?? ""))
        })
        
        return modelsList
    }
    
//    private func convertVersesListIntoViewModel(_ coreDataVersesList: NSOrderedSet?) -> [WVerse]? {
//        guard let coreDataVersesList = coreDataVersesList else {
//            return nil
//        }
//
//        var modelsList = [WVerse]()
//        for verse in coreDataVersesList {
//            guard let verse = verse as? CDVerse else {
//                continue
//            }
//
//            modelsList.append(WVerse(sanskrit: verse.sanskrit ?? "",
//                                     english: verse.english ?? "",
//                                     iast: verse.iast ?? ""))
//        }
//        
//        return modelsList
//    }
    
}
