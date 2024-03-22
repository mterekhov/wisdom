import Foundation
import CoreData

enum WBooksServiceError: String, LocalizedError {
    
    case failedToSendRequest = "BookServiceError.FailedSendRequest"
    case coreDataError = "BookServiceError.CoreDataError"
    case bookNotFound = "BookServiceError.BookNotFound"
    
    var localizedDescription: String { return self.rawValue.local }
    
}

protocol WBooksServiceProtocol {
    
    func downloadBooksList() async -> Result<[WBook], Error>
    func downloadVersesList(bookUUID: String) async -> Result<[WVerse], Error>
    
    func fetchBook(bookUUID: String) async -> WBook?
    func fetchBooksList(filterString: String?) async -> Result<[WBook], Error>
    func fetchVerse(bookUUID: String, verseIndex: Int, localContext: NSManagedObjectContext) -> CDVerse?

    func saveBooksList(booksList: [WBook]) async
    func saveVersesList(bookUUID: String, versesList: [WVerse]) async
    
}

class WBooksService: WBooksServiceProtocol {
    
    private let ResponsesListKey = "responses_list"
    private let SanskritKey = "sanskrit"
    private let EnglishKey = "english"
    private let IASTKey = "iast"
    private let IndexKey = "index"
    private let UUIDKey = "uuid"
    
    var coreDataService: WCoreDataServiceProtocol
    var jnanaAPIService: WJnanaAPIServiceProtocol
    
    init(_ coreDataService: WCoreDataServiceProtocol, _ jnanaAPIService: WJnanaAPIServiceProtocol) {
        self.coreDataService = coreDataService
        self.jnanaAPIService = jnanaAPIService
    }
    
    //  MARK: - WBooksServiceProtocol -
    
    func downloadVersesList(bookUUID: String) async -> Result<[WVerse], Error> {
        let result = await jnanaAPIService.bookContent(bookUUID)
        switch result {
        case .success(let versesListJSON):
            return .success(parseJSONVersesList(json: versesListJSON))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func downloadBooksList() async -> Result<[WBook], Error> {
        let result = await jnanaAPIService.booksList()
        switch result {
        case .success(let booksJSON):
            return .success(parseJSONBook(json: booksJSON))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetchBook(bookUUID: String) async -> WBook? {
        let localContext = coreDataService.newLocalContext()
        var result: WBook?
        
        await localContext.perform {
            if let coredataBook = self.fetchSingleBook(bookUUID: bookUUID,
                                                       localContext: localContext) {
                result = self.convertBookIntoViewModel(coredataBook)
            }
        }
        
        return result
    }
    
    func fetchBooksList(filterString: String?) async -> Result<[WBook], Error> {
        var filterDictionary: [String:String]?
        if let filterString = filterString {
            filterDictionary = [EnglishKey: filterString]
        }
        
        let localContext = coreDataService.newLocalContext()
        var result = Result<[WBook], Error>.failure(WBooksServiceError.coreDataError)
        await localContext.perform {
            do {
                let coredataBooksList = try localContext.fetch(WBook.createFetchRequest(filterDictionary)) as? [CDBook]
                result = .success(self.convertBooksListIntoViewModel(coredataBooksList))
            }
            catch (_) {
            }
        }
        
        return result
    }

    func fetchVerse(bookUUID: String, verseIndex: Int, localContext: NSManagedObjectContext) -> CDVerse? {
        guard let coredataBook = fetchSingleBook(bookUUID: bookUUID, localContext: localContext) else {
            return nil
        }
        
        guard let versesList = coredataBook.versesList as? Set<CDVerse> else {
            return nil
        }

        return versesList.first { verse in
            return verse.index == verseIndex
        }
    }
    
    func saveVersesList(bookUUID: String, versesList: [WVerse]) async {
        let localContext = coreDataService.newLocalContext()
        await localContext.perform {
            //  Find book by uuid
            guard let firstCoreDataBook = self.fetchSingleBook(bookUUID: bookUUID,
                                                               localContext: localContext) else {
                return
            }
            
            //  delete old verses of this book
            if let oldCoreDataVersesList = firstCoreDataBook.versesList as? Set<CDVerse> {
                oldCoreDataVersesList.forEach { verse in
                    localContext.delete(verse)
                }
            }
            
            //  create new verses
            versesList.forEach { verse in
                let newVerse = CDVerse(context: localContext)
                newVerse.sanskrit = verse.sanskrit
                newVerse.iast = verse.iast
                newVerse.english = verse.english
                newVerse.index = Int64(verse.index)
                firstCoreDataBook.addToVersesList(newVerse)
            }
            
            //  save context
            localContext.wisdom_saveContext()
        }
    }
    
    func saveBooksList(booksList: [WBook]) async {
        for i in 0..<booksList.count {
            let book = booksList[i]
            let localContext = coreDataService.newLocalContext()
            await localContext.perform {
                guard let existingCoreDataBook = self.fetchSingleBook(bookUUID: book.uuid,
                                                                      localContext: localContext) else {
                    let newBook = CDBook(context: localContext)
                    newBook.sanskrit = book.sanskrit
                    newBook.iast = book.iast
                    newBook.english = book.english
                    newBook.uuid = book.uuid
                    localContext.wisdom_saveContext()
                    return
                }
            }
        }
    }
    
    //  MARK: - Routine -
    
    private func fetchSingleBook(bookUUID: String, localContext: NSManagedObjectContext) -> CDBook? {
        do {
            guard let coredataBooksList = try localContext.fetch(WBook.createFetchRequest([UUIDKey: bookUUID])) as? [CDBook],
                  coredataBooksList.count < 2,
                  let firstCoreDataBook = coredataBooksList.first else {
                return nil
            }
            
            return firstCoreDataBook
        }
        catch (_) {
            return nil
        }
    }
    
    private func fetchBook(_ filter: [String:String]?) async -> Result<[WBook], Error> {
        var result: Result<[WBook], Error> = .failure(WBooksServiceError.coreDataError)
        
        do {
            let localContext = coreDataService.newLocalContext()
            try await localContext.perform {
                guard let coredataBooksList = try localContext.execute(WBook.createFetchRequest(filter)) as? [CDBook] else {
                    return
                }
                result = .success(self.convertBooksListIntoViewModel(coredataBooksList))
            }
        }
        catch _ {
        }
        
        return result
    }
    
    private func convertBookIntoViewModel(_ coredataBook: CDBook) -> WBook {
        var newBook = WBook(sanskrit: coredataBook.sanskrit ?? "",
                            english: coredataBook.english ?? "",
                            iast: coredataBook.iast ?? "",
                            uuid: coredataBook.uuid ?? "")
        newBook.versesList = convertVersesListIntoViewModel(coredataBook.versesList)
        return newBook
    }
    
    private func convertBooksListIntoViewModel(_ coreDataBooksList: [CDBook]?) -> [WBook] {
        var modelsList = [WBook]()
        
        guard let coreDataBooksList = coreDataBooksList else {
            return modelsList
        }
        
        coreDataBooksList.forEach({ book in
            modelsList.append(convertBookIntoViewModel(book))
        })
        
        return modelsList
    }
    
    private func convertVersesListIntoViewModel(_ coreDataVersesList: NSSet?) -> [WVerse]? {
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
                                     iast: verse.iast ?? "",
                                     index: Int(verse.index)))
        }
        
        return modelsList.sorted { verse1, verse2 in
            return verse1.index < verse2.index
        }
    }
    
    private func parseJSONBook(json: [String:Any]) -> [WBook] {
        var booksList = [WBook]()
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
    
}
