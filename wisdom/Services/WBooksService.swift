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
typealias VoidCompletionHandler = () -> Void

protocol WBooksServiceProtocol {
    
    func saveBooksList(_ booksList: [WBook], _ completionHandler: @escaping VoidCompletionHandler)
    func fetchBooksList(_ searchTitleString: String?, _ completionBlock: @escaping BooksListFetchCompletionHandler)
    func downloadBooksList(_ completionBlock: @escaping BooksListDownloadCompletionHandler)
    
}

class WBooksService: WBooksServiceProtocol {

    var coreDataService: WCoreDataServiceProtocol?
    var jnanaAPIService: WJnanaAPIServiceProtocol

    init(_ coreDataService: WCoreDataServiceProtocol?, _ jnanaAPIService: WJnanaAPIServiceProtocol) {
        self.coreDataService = coreDataService
        self.jnanaAPIService = jnanaAPIService
    }

    //  MARK: - WTextsServiceProtocol -

    private func doesBookExists(_ bookID: String, localContext: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CDBook.entity().name ?? "")
        fetchRequest.predicate = NSPredicate(format: "uuid CONTAINS[cd] %@", bookID)

        do {
            guard let coredataBooksList = try localContext.fetch(fetchRequest) as? [CDBook] else {
                return false
            }
            
            if coredataBooksList.count > 0 {
                return true
            }
        }
        catch _ {
            return false
        }
        
        return false
    }
    
    func saveBooksList(_ booksList: [WBook], _ completionHandler: @escaping VoidCompletionHandler) {
        guard let coreDataService = coreDataService else {
            completionHandler()
            return
        }
        
        coreDataService.asyncExecute { [weak self] localContext in
            guard let self = self else { return }
            booksList.forEach { book in
                if self.doesBookExists(book.uuid, localContext: localContext) == false {
                    let newBook = CDBook(context: localContext)
                    newBook.sanskrit = book.sanskrit
                    newBook.iast = book.iast
                    newBook.english = book.english
                    newBook.uuid = book.uuid
                    localContext.wisdom_saveContext()
                }
            }
            
            completionHandler()
        }
    }
    
    func fetchBooksList(_ searchTitleString: String?, _ completionBlock: @escaping BooksListFetchCompletionHandler) {
        guard let coreDataService = coreDataService else {
            completionBlock(.failure(WBooksServiceError.coreDataError))
            return
        }

        coreDataService.asyncExecute { [weak self] localContext in
            guard let self = self else {
                return
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CDBook.entity().name ?? "")
            if let searchTitleString = searchTitleString,
               !searchTitleString.isEmpty {
                fetchRequest.predicate = NSPredicate(format: "english CONTAINS[cd] %@", searchTitleString)
            }

            do {
                guard let coredataBooksList = try localContext.fetch(fetchRequest) as? [CDBook] else {
                    completionBlock(.failure(WBooksServiceError.coreDataError))
                    return
                }
                completionBlock(.success(self.convertBooksListIntoViewModel(coredataBooksList)))
            }
            catch _ {
                completionBlock(.failure(WBooksServiceError.coreDataError))
                return
            }
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

    private func parseJSONBook(json: [String:Any]) -> [WBook] {
        var booksList =  [WBook]()
        guard let responsesList = json["responses_list"] as? [[String:Any]] else { return booksList };
        guard let booksListResponse = responsesList.first else { return booksList }
        guard let payload = booksListResponse["payload"] as? [[String:Any]] else { return booksList };
        payload.forEach { bookJSON in
            let newBook = WBook(sanskrit: (bookJSON["sanskrit"] as? String) ?? "",
                                english: (bookJSON["english"] as? String) ?? "",
                                iast: (bookJSON["iast"] as? String) ?? "",
                                uuid: (bookJSON["book_id"] as? String) ?? "")
            booksList.append(newBook)
        }
        
        return booksList
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
