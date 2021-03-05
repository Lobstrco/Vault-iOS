import Foundation
import UIKit

struct TransactionDetailsSection {
  var type: TransactionDetailsSectionType
  var rows: [TransactionDetailsRow]
}

enum TransactionDetailsRow {
  case operation(String)
  case operationDetail((name: String , value: String))
  case additionalInformation((name: String , value: String))
  case signer(SignerViewData)
}

enum TransactionDetailsSectionType {
  case operations
  case operationDetails
  case additionalInformation
  case signers
  
  var rowHeight: CGFloat {
    switch self {
    case .operations: return 50.0
    case .operationDetails: return 50.0
    case .additionalInformation: return 50.0
    case .signers: return 70.0
    }
  }
  
  var headerHeight: CGFloat {
    switch self {
    case .operations: return 0
    case .operationDetails: return 0
    case .additionalInformation: return 0
    case .signers: return 40
    }
  }
  
  var index: Int {
    switch self {
    case .operationDetails: return 0
    case .operations: return 0
    case .additionalInformation: return 1
    case .signers: return 2
    }
  }
}
