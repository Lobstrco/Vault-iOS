import stellarsdk

extension OperationType {
  
  var description: String {
    get {
      switch self {
      case .accountCreated:
        return "Account Created"
      case .accountMerge:
        return "Account Merge"
      case .allowTrust:
        return "Allow Trust"
      case .bumpSequence:
        return "Bump Sequence"
      case .changeTrust:
        return "Change Trust"
      case .inflation:
        return "Inflation"
      case .manageData:
        return "Manage Data"
      case .pathPayment:
        return "Path Payment"
      case .payment:
        return "Payment"
      case .setOptions:
        return "Set Options"
      case .createPassiveSellOffer:
        return "Create Passive Offer"
      case .manageBuyOffer:
        return "Buy Offer"
      case .manageSellOffer:
        return "Sell Offer"
      case .pathPaymentStrictSend:
        return "Path Payment Strict Send"
      default: return "Unknown"
      }
    }
  }
}
