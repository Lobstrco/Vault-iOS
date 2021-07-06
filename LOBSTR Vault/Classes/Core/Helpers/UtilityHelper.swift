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
    let sUrl = "https://shop.tangem.com/products/tangem-for-lobstr-vault"
    guard let url = URL(string: sUrl) else { return }
    UIApplication.shared.open(url, options: .init(), completionHandler: nil)
  }
  
  static func createBodyEmail() -> String {
    let vaultStorage = VaultStorage()
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return "" }
    
    let bodyEmail = "Information for the support team." +
      "\nLOBSTR Vault. App version: \(ApplicationInfo.version);" +
      "\nVault public key: \(publicKeyFromKeychain);" +
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
  
  static func jwtTokenExpired() -> Bool {
    guard let jwtToken = VaultStorage().getJWTFromKeychain() else { return true }
    guard let jwt = try? decode(jwt: jwtToken) else { return true }
    
    return jwt.expired
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
          HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting))
        }
      }
      AuthenticationService().updateToken() { result in
        HUD.hide()
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
}

