import Foundation
import UIKit

enum FreshDeskArticle: String {
  case recoveryPhrase = "151000001282"
  case recoverAccount = "151000001581"
  case signingTangem = "151000001342"
  case addXdrManually = "151000001584"
  case transactionConfirmations = "151000001333"
  case allowUnsignedTransactions = "151000001285"
  case iCloudSync = "151000052999"
}

struct FreshDeskHelper {
  static let helpCenter = "https://lobstrvault.freshdesk.com/support/home"
  static let createTicket = "https://lobstr.freshdesk.com/support/tickets/new"
  static let articlesUrl = "https://lobstrvault.freshdesk.com/support/solutions/articles/"
  
  static var helpCenterURL: URL {
    return URL(string: helpCenter)!
  }
  
  static var createTicketURL: URL {
    return URL(string: createTicket)!
  }
  
  private static func createArticleURL(id: FreshDeskArticle) -> URL {
    let urlString = "\(articlesUrl)\(id.rawValue)"
    let url = URL(string: urlString)!
    return url
  }
  
  static func getHelpCenterController() -> UIViewController {
    let safariViewController = MainSafariViewController(url: helpCenterURL)
    safariViewController.modalPresentationStyle = .pageSheet
    return safariViewController
  }
  
  static func getFreshDeskArticleController(article: FreshDeskArticle) -> UIViewController {
    let safariViewController = MainSafariViewController(url: createArticleURL(id: article))
    safariViewController.modalPresentationStyle = .pageSheet
    return safariViewController
  }
}
