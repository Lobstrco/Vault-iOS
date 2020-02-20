import UIKit

struct SignerViewData {
  let status: SignatureStatus
  let publicKey: String
  let weight: Int
  var federation: String?
  let isLocalPublicKey: Bool
  
  var statusText: String {
    switch status {
    case .accepted:
      return "Signed"
    case .pending:
      return "Pending"
    }
  }
  
  var statusColor: UIColor {
    switch status {
    case .accepted:
      return Asset.Colors.confirm.color
    case .pending:
      return Asset.Colors.pending.color
    }
  }
}
