import Foundation
import UIKit

struct OperationDetailsSection {
  var type: OperationDetailsSectionType
  var rows: [OperationDetailsRow]
}

enum OperationDetailsRow {
  case additionalInformation((name: String, value: String, nickname: String, isPublicKey: Bool))
  case operationDetail((name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool))
  case signer(SignerViewData)
}

enum OperationDetailsSectionType {
  case additionalInformation
  case operationDetails
  case signers
  
  var rowHeight: CGFloat {
    switch self {
    case .additionalInformation: return 50.0
    case .operationDetails: return 50.0
    case .signers: return 70.0
    }
  }
  
  var headerHeight: CGFloat {
    switch self {
    case .additionalInformation: return 0
    case .operationDetails: return 40
    case .signers: return 40
    }
  }
  
  var index: Int {
    switch self {
    case .additionalInformation: return 0
    case .operationDetails: return 0
    case .signers: return 2
    }
  }
}
