import stellarsdk

extension OperationType {
  var description: String {
    switch self {
    case .accountCreated:
      return L10n.textAccountCreated
    case .accountMerge:
      return L10n.textAccountMerge
    case .allowTrust:
      return L10n.textAllowTrust
    case .bumpSequence:
      return L10n.textBumpSequence
    case .changeTrust:
      return L10n.textChangeTrust
    case .inflation:
      return L10n.textInflation
    case .manageData:
      return L10n.textManageData
    case .pathPayment:
      return L10n.textPathPaymentStrictReceive
    case .payment:
      return L10n.textPayment
    case .setOptions:
      return L10n.textSetOptions
    case .createPassiveSellOffer:
      return L10n.textCreatePassiveOffer
    case .manageBuyOffer:
      return L10n.textBuyOffer
    case .manageSellOffer:
      return L10n.textSellOffer
    case .pathPaymentStrictSend:
      return L10n.textPathPaymentStrictSend
    case .beginSponsoringFutureReserves:
      return L10n.textBeginSponsoringFutureReserves
    case .endSponsoringFutureReserves:
      return L10n.textEndSponsoringFutureReserves
    case .revokeSponsorship:
      return L10n.textRevokeSponsorship
    case .createClaimableBalance:
      return L10n.textCreateClaimableBalance
    case .claimClaimableBalance:
      return L10n.textClaimClaimableBalance
    case .clawback:
      return L10n.textClawback
    case .clawbackClaimableBalance:
      return L10n.textClawbackClaimableBalance
    case .setTrustLineFlags:
      return L10n.textSetTrustlineFlags
    case .liquidityPoolDeposit:
      return L10n.textLiquidityPoolDeposit
    case .liquidityPoolWithdraw:
      return L10n.textLiquidityPoolWithdraw
    case .extendFootprintTTL:
      return L10n.textExtendFootprintTtl
    case .restoreFootprint:
      return L10n.textRestoreFootprint
    case .invokeHostFunction:
      return L10n.textInvokeHostFunction
    default: return L10n.textUnknown
    }
  }
}

extension OperationResultXDR {
  var description: String {
    switch self {
    case .createAccount:
      return L10n.textAccountCreated
    case .accountMerge:
      return L10n.textAccountMerge
    case .allowTrust:
      return L10n.textAllowTrust
    case .bumpSequence:
      return L10n.textBumpSequence
    case .changeTrust:
      return L10n.textChangeTrust
    case .inflation:
      return L10n.textInflation
    case .manageData:
      return L10n.textManageData
    case .pathPayment:
      return L10n.textPathPaymentStrictReceive
    case .payment:
      return L10n.textPayment
    case .setOptions:
      return L10n.textSetOptions
    case .createPassiveSellOffer:
      return L10n.textCreatePassiveOffer
    case .manageBuyOffer:
      return L10n.textBuyOffer
    case .manageSellOffer:
      return L10n.textSellOffer
    case .pathPaymentStrictSend:
      return L10n.textPathPaymentStrictSend
    case .beginSponsoringFutureReserves:
      return L10n.textBeginSponsoringFutureReserves
    case .endSponsoringFutureReserves:
      return L10n.textEndSponsoringFutureReserves
    case .revokeSponsorship:
      return L10n.textRevokeSponsorship
    case .createClaimableBalance:
      return L10n.textCreateClaimableBalance
    case .claimClaimableBalance:
      return L10n.textClaimClaimableBalance
    case .clawback:
      return L10n.textClawback
    case .clawbackClaimableBalance:
      return L10n.textClawbackClaimableBalance
    case .setTrustLineFlags:
      return L10n.textSetTrustlineFlags
    case .liquidityPoolDeposit:
      return L10n.textLiquidityPoolDeposit
    case .liquidityPoolWithdraw:
      return L10n.textLiquidityPoolWithdraw
    case .extendFootprintTTL:
      return L10n.textExtendFootprintTtl
    case .restoreFootprint:
      return L10n.textRestoreFootprint
    case .invokeHostFunction:
      return L10n.textInvokeHostFunction
    default: return ""
    }
  }
}
