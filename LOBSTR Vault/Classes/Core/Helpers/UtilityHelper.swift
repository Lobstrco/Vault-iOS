import Foundation
import UIKit
import JWTDecode

import PKHUD

struct UtilityHelper {
  
  static func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)
      
      if let output = filter.outputImage?.transformed(by: transform) {
        
        let colorParameters = [
          "inputColor0": CIColor(color: Asset.Colors.main.color),
          "inputColor1": CIColor(color: UIColor.clear)
        ]
        let colored = output.applyingFilter("CIFalseColor", parameters: colorParameters)

        
        return UIImage(ciImage: colored)
      }
    }
    
    return nil
  }
  
  static func openStellarExpertForPublicKey(publicKey: String) {
    let sUrl = "https://stellar.expert/explorer/public/account/\(publicKey)"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func openStellarExpertForAsset(assetCode: String, assetIssuer: String) {
    let sUrl = "https://stellar.expert/explorer/public/asset/\(assetCode)-\(assetIssuer)"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func openStellarExpertForNativeAsset() {
    let sUrl = "https://stellar.expert/explorer/public/asset/XLM"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func openStellarLaboratory(for xdr: String) {
    let replacedXdr = xdr.replacingOccurrences(of: "+", with: "%2B")
    let sUrl = "https://laboratory.stellar.org/#xdr-viewer?input=\(replacedXdr)&type=TransactionEnvelope&network=public"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func openVaultLanding() {
    let sUrl = "https://vault.lobstr.co"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func openTangemVaultLanding() {
    let sUrl = "https://vault.lobstr.co/card"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func openTangemShop() {
    let sUrl = "https://lobstr.tangem.com"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func createBodyEmail() -> String {
    let publicKey = UserDefaultsHelper.activePublicKey
    let bodyEmail = "Information for the support team." +
      "\nLOBSTR Vault. App version: \(ApplicationInfo.version);" +
      "\nVault public key: \(publicKey);" +
      "\nDevice brand: Apple;" +
      "\nModel: \(UIDevice.modelName);" +
      "\nOS: iOS;" +
      "\nOS version: \(UIDevice.current.systemVersion);\n" +
      "\nDescribe an issue or provide your feedback below:"
    return bodyEmail
  }

  
  static func createEmailUrl(to: String, subject: String, body: String) -> URL? {
      let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    
      let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
      let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
      let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
      let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

      if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
       return gmailUrl
      } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
       return outlookUrl
      } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
       return yahooMail
      }

      return defaultUrl
  }
  
  static func jwtTokenUpdate() {
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      if let topVC = UIApplication.getTopViewController() {
        if !(topVC is PinEnterViewController) {
          DispatchQueue.main.async {
            HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting))
          }
        }
      }
      AuthenticationService().updateToken() { result in
        DispatchQueue.main.async {
          HUD.hide()
        }
        switch result {
        case .success(_):
          NotificationCenter.default.post(name: .didJWTTokenUpdate, object: nil)
        case .failure(let error):
          Logger.auth.error("Couldn't update token with error: \(error)")
        }
      }
    default:
      Logger.auth.error("Fatal error")
    }
  }
  
  static func jwtTokensExpired() -> [String: Bool] {
    var result: [String: Bool] = [:]
    guard let jwtTokens = VaultStorage().getJWTTokensFromKeychain() else { return result }
    for key in jwtTokens.keys {
      if let jwtToken = jwtTokens[key], let jwt = try? decode(jwt: jwtToken) {
        result[key] = jwt.expired
      }
    }
    return result
  }
  
  static func jwtTokenExpired() -> Bool {
    // Multiaccount support case
    if let jwtTokens = VaultStorage().getJWTTokensFromKeychain() {
      guard let key = jwtTokens.keys.first(where: { key in
        key == UserDefaultsHelper.activePublicKey
      }) else { return true }
      guard let jwtToken = jwtTokens[key] else { return true }
      guard let jwt = try? decode(jwt: jwtToken) else { return true }
      return jwt.expired
    }
    // One account
    else if let jwtToken = VaultStorage().getJWTFromKeychain() {
      guard let jwt = try? decode(jwt: jwtToken) else { return true }
      return jwt.expired
    } else {
      return true
    }
  }
  
  static func isTokenUpdated(view: UIViewController) -> Bool {
    guard UtilityHelper.jwtTokenExpired() else {
      return true
    }
    
    switch UserDefaultsHelper.accountStatus {
    case .createdWithTangem:
      let authenticationViewController = AuthenticationViewController.createFromStoryboard()
      view.navigationController?.present(authenticationViewController, animated: true, completion: nil)
    case .createdByDefault:
      if let topVC = UIApplication.getTopViewController() {
        if !(topVC is PinEnterViewController) {
          DispatchQueue.main.async {
            HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting))
          }
        }
      }
      AuthenticationService().updateToken() { result in
        DispatchQueue.main.async {
          HUD.hide()
        }
        switch result {
        case .success(_):
          NotificationCenter.default.post(name: .didJWTTokenUpdate, object: nil)
        case .failure(let error):
          Logger.auth.error("Couldn't update token with error: \(error)")
        }
      }
    default:
      Logger.auth.error("Fatal error")
    }
    
    return !UtilityHelper.jwtTokenExpired()
  }
  
  static func checkAllJWTTokens() {
    guard let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain(), publicKeysFromKeychain.count > 1 else { return }
    
    let jwtTokensStatuses = UtilityHelper.jwtTokensExpired()
      
    if jwtTokensStatuses.isEmpty {
      getAllJWTTokens(for: publicKeysFromKeychain)
    } else {
      updateExpiredTokens()
    }
  }
  
  static func getAllJWTTokens(for publicKeysFromKeychain: [String]) {
    let jwtManager: JWTManager = JWTManagerImpl()
    var jwtTokens: [String: String] = [:]
    for index in 0 ... publicKeysFromKeychain.count - 1 {
      AuthenticationService().getToken(for: index) { result in
        switch result {
        case .success(let jwtToken):
          if let key = jwtToken.keys.first, let value = jwtToken.values.first {
            jwtTokens[key] = value
            if jwtTokens.count == publicKeysFromKeychain.count {
              if jwtManager.store(jwtTokens: jwtTokens) {
                NotificationCenter.default.post(name: .didAllJWTTokensGet, object: nil)
              }
            }
          }
        case .failure:
          break
        }
      }
    }
  }
  
  static func getPublicKeysForExpiredTokens() -> [String] {
    let jwtTokensStatuses = UtilityHelper.jwtTokensExpired()
    var expiredKeys: [String] = []
    for key in jwtTokensStatuses.keys {
      guard let isExpired = jwtTokensStatuses[key] else { return expiredKeys }
      if isExpired {
        expiredKeys.append(key)
      }
    }
    return expiredKeys
  }
  
  static func updateExpiredTokens() {
    guard let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain() else { return }
    guard let jwtTokens = VaultStorage().getJWTTokensFromKeychain() else { return }
    let expiredKeys = getPublicKeysForExpiredTokens()
    for key in expiredKeys {
      if let index = publicKeysFromKeychain.firstIndex(of: key), let token = jwtTokens[key] {
        AuthenticationService().updateToken(for: index, with: token) { result in
          switch result {
          case .success:
            break
          case .failure:
            break
          }
        }
      }
    }
  }
}
