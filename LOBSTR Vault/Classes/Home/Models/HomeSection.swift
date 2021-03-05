import Foundation
import UIKit

public struct HomeSection {
  var type: HomeSectionType
  var rows: [HomeRow]
}

public enum HomeRow {  
  case numberOfTransactions(String)
  case publicKey(String)
  case totalNumber(Int)
  case signer(SignedAccount)  
  case bottom
  
  var height: CGFloat {
    switch self {
    case .numberOfTransactions: return 230.0
    case .publicKey: return 240.0
    case .totalNumber: return 60.0
    case .signer: return 80.0
    case .bottom: return 100.0
    }
  }
}

public enum HomeSectionType {
  case transactionsToSign
  case vaultPublicKey
  case signersTotalNumber
  case listOfSigners
  case bottom

  var index: Int {
    switch self {
    case .transactionsToSign: return 0
    case .vaultPublicKey: return 1
    case .signersTotalNumber: return 2
    case .listOfSigners: return 3
    case .bottom: return 4
    }
  }
}

