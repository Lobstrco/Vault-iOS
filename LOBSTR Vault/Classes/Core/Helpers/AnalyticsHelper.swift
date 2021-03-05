import Foundation
import FirebaseAnalytics

enum OnboardingEvent: String {
  case start = "onboard_start"
  case termsOfServiceButton = "onboard_tos"
  case privacyPolicyButton = "onboard_pp"
  
  // tangem 
  case tangemSignInButton = "onboard_tg_sign_in"
  case tangemScanSuccess = "onboard_tg_scan_success"
  case tangemScanFailure = "onboard_tg_scan_failure"
  case tangemLearnMoreButton = "onboard_tg_learm_more"
  case tangemBuyNowButton = "onboard_tg_buy_now"
  case tangemSignInSuccess = "onboard_tg_sign_in_success"
  case tangemSignInFailure = "onboard_tg_sign_in_failure"
  case tangemCreateWalletSuccess = "onboard_tg_create_wallet_success"
  case tangemCreateWalletFailure = "onboard_tg_create_wallet_failure"
  
  case onboardBackButton = "onboard_back_button"
}


struct AnalyticsHelper {
    
  static func launchOnboardingEvent(event: OnboardingEvent, parameters: [String: Any]? = nil) {
    Analytics.logEvent(event.rawValue, parameters: parameters)
  }

}
