import Crashlytics
import Foundation

class CrashlyticsService {
  func recordCustomException(_ error: Error) {
    return
    /*
    let errorInfo = (error as! ErrorDisplayable).displayData
    Crashlytics.sharedInstance()
      .recordCustomExceptionName(errorInfo.titleKey.localized(),
                                 reason: errorInfo.messageKey.localized(),
                                 frameArray: [])
    */
  }
}
