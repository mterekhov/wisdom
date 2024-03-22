import Foundation
import CoreData

struct WBook: Identifiable, Hashable {
    
    static func == (lhs: WBook, rhs: WBook) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    var versesList: [WVerse]?
    var sanskrit: String
    var english: String
    var iast: String
    var uuid: String
    
    var id:String { uuid }

}

extension WBook {

    static func createFetchRequest(_ filter: [String:String]?) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CDBook.entity().name ?? "")

        if let filter = filter {
            var predicateString = ""
            filter.forEach { (key: String, value: String) in
                predicateString += "(\(key) CONTAINS[CD] '\(value)') AND "
            }
            predicateString.removeLast(5)
            fetchRequest.predicate = NSPredicate(format: predicateString)
        }
        
        return fetchRequest
    }
    
}
