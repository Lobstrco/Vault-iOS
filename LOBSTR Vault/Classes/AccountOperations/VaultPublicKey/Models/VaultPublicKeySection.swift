import UIKit

public struct VaultPublicKeySection {
  var type: VaultPublicKeySectionType
  var rows: [VaultPublicKeyRow]
}

public enum VaultPublicKeyRow {
  case usingLobstrWallet(LobstrCheckResult)
  case usingDifferentService(String)
  
  var height: CGFloat {
    switch self {
    case .usingLobstrWallet: return 240.0
    case .usingDifferentService: return 250.0
    }
  }
}

public enum VaultPublicKeySectionType {
  case main
}

