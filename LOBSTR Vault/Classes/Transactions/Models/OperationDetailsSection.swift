import Foundation
import UIKit

struct OperationDetailsSection {
  var type: OperationDetailsSectionType
  var rows: [OperationDetailsRow]
}

enum OperationDetailsRow {
  case operationDetail((name: String , value: String))
  case signer(SignerViewData)
}

enum OperationDetailsSectionType {
  case operationDetails
  case signers
  
  var rowHeight: CGFloat {
    switch self {
    case .operationDetails: return 50.0
    case .signers: return 70.0
    }
  }
  
  var headerHeight: CGFloat {
    switch self {
    case .operationDetails: return 0
    case .signers: return 40
    }
  }
  
  var index: Int {
    switch self {
    case .operationDetails: return 0
    case .signers: return 1
    }
  }
}
