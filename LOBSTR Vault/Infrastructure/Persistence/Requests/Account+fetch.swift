import Foundation
import CoreData

extension Account {
  static func fetchBy(publicKey: String) -> NSFetchRequest<Account> {
    let request:NSFetchRequest<Account> = Account.fetchRequest()
    request.predicate = NSPredicate(format: "%K == %@", #keyPath(Account.publicKey), publicKey)
    return request
  }
}
