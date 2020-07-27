import CoreData

protocol Findable: NSManagedObject {
    static func findAll() -> NSFetchRequest<Self>
}
