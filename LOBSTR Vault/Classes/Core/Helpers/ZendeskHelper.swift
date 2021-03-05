import Foundation
import SupportSDK

enum ZendeskArticle: String {
  case recoveryPhrase = "360013259599"
  case recoverAccount = "360013243520"
  case signingTangem = "360013838099"
  case addXdrManually = "360013304599"  
}

struct ZendeskHelper {
    
  static let appId = "39def0bafc375420e23c9d6328d980f7d4faee26b9c7b785"
  static let clientId = "mobile_sdk_client_51bd93aaa101db951c12"
  static let zendeskUrl = "https://vault.zendesk.com"
  
  static func getZendeskArticleController(article: ZendeskArticle) -> UIViewController {
    return HelpCenterUi.buildHelpCenterArticleUi(withArticleId: article.rawValue, andConfigs: [])
  }
  
  static func getHelpCenterController() -> UIViewController {
    return HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [])
  }
}
