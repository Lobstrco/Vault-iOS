import Foundation
import CoreData

class CoreDataStack {
  
  static let shared = CoreDataStack(modelName: "Vault")
  
  lazy var managedContext: NSManagedObjectContext = {
    persistentContainer.viewContext
  }()
  
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: modelName)
    
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      print("storeDescription = \(storeDescription)")
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  } ()
  
  private let modelName: String
  
  private init(modelName: String) {
    self.modelName = modelName
  }
  
  func fetch<T>(_ request: NSFetchRequest<T>) -> [T] where T : NSFetchRequestResult {
    do {
      return try managedContext.fetch(request)
    } catch let error as NSError {
      Logger.persistence.error("Fetch error \(error), \(error.userInfo)")
    }
    return []
  }
  
  func create<T>(_ request: NSFetchRequest<T>) -> T where T : NSManagedObject {
    return NSManagedObject(entity: T.entity(), insertInto: managedContext) as! T
  }
  
  func saveContext() {
    guard managedContext.hasChanges else { return }
    do {
      try managedContext.save()
    } catch let error as NSError {
      Logger.persistence.error("Save error \(error), \(error.userInfo)")
    }
  }
}
