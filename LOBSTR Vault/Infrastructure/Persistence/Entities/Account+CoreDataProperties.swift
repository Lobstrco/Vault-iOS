import Foundation
import CoreData

extension Account {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
    return NSFetchRequest<Account>(entityName: "Account")
  }

  @NSManaged public var federation: String?
  @NSManaged public var publicKey: String
}
