import Foundation
import stellarsdk

struct TransactionHelper {
  
  static let storage: AccountsStorage = AccountsStorageDiskImpl()
  static var storageAccounts: [SignedAccount] = []
  
  static let numberOfCharacters = getNumberOfCharactersForTruncatePublicKeyTransactionDetails()
  
  // tangem auth sep-10 and tangem sign transaction
  static func signTransaction(walletPublicKey: Data, signature: Data, txEnvelope: inout TransactionEnvelopeXDR) {
    let publicKeyData = walletPublicKey.toBytes
    let hint = Data(bytes: publicKeyData, count: publicKeyData.count).suffix(4)

    let decoratedSignature = DecoratedSignatureXDR(hint: WrappedData4(hint), signature: signature)
    txEnvelope.appendSignature(signature: decoratedSignature)
  }
  
  // auth sep-10 and sign transaction
  static func signTransaction(transactionEnvelopeXDR: inout TransactionEnvelopeXDR, userKeyPair: KeyPair) throws {
    let transactionHash = try [UInt8](transactionEnvelopeXDR.txHash(network: .public))
    transactionEnvelopeXDR.appendSignature(signature: userKeyPair.signDecorated(transactionHash))
  }
  
  static func isThereVerifiedSignature(for publicKey: String, in envelopeXDR: TransactionEnvelopeXDR) -> Bool {
    let transformedEnvelopeXDR = tryToTransformTransactionXDRV0ToV1(envelopeXDR: envelopeXDR)
    
    guard let transactionHash = try? [UInt8](transformedEnvelopeXDR.txHash(network: .public)) else { return false }
    guard let signerKeyPair = try? KeyPair(accountId: publicKey) else { return false }

    for signature in transformedEnvelopeXDR.txSignatures {
      do {
        let signatureIsValid = try signerKeyPair.verify(signature: [UInt8](signature.signature), message: transactionHash)
        if signatureIsValid { return true }
      } catch {
        Logger.transactionDetails.error("Couldn't verify signature")
        return false
      }
    }

    return false
  }
  
  static func tryToTransformTransactionXDRV0ToV1(envelopeXDR: TransactionEnvelopeXDR) -> TransactionEnvelopeXDR {
    var transformedEnvelopeXDR = envelopeXDR
    switch transformedEnvelopeXDR {
    case .v0(let txEnvV0):
      let tV0Xdr = txEnvV0.tx
      guard let pk = try? PublicKey(tV0Xdr.sourceAccountEd25519) else { break }
      let transactionXdr = TransactionXDR(sourceAccount: pk,
                                          seqNum: tV0Xdr.seqNum,
                                          timeBounds: tV0Xdr.timeBounds,
                                          memo: tV0Xdr.memo,
                                          operations: tV0Xdr.operations,
                                          maxOperationFee: tV0Xdr.fee / UInt32(tV0Xdr.operations.count))
      let txV1E = TransactionV1EnvelopeXDR(tx: transactionXdr, signatures: transformedEnvelopeXDR.txSignatures)
      transformedEnvelopeXDR = TransactionEnvelopeXDR.v1(txV1E)
    default:
      break
    }
    
    return transformedEnvelopeXDR
  }
  
  static func getListOfOperationNames(from xdr: TransactionEnvelopeXDR, transactionType: ServerTransactionType?) throws -> [String] {
    var operationNames: [String] = []
    
    for operation in xdr.txOperations {
      let operationTypeValue = operation.body.type()
    
      let operationType = OperationType.init(rawValue: operationTypeValue)
    
      if let type = operationType {
        var name = ""
        switch type {
        case .accountCreated:
          name = "Create Account"
        case .manageSellOffer:
          guard let manageOperation = try? stellarsdk.Operation.fromXDR(operationXDR: operation) as? ManageOfferOperation else {
            name = "Sell Offer"
            continue
          }
          name = manageOperation.amount == 0 && manageOperation.offerId != 0 ? "Cancel Offer" : "Sell Offer"
        case .manageData:
          if let transactionType = transactionType {
            switch transactionType {
            case .authChallenge:
              name = L10n.textOperationNameChallengeTitle
            default:
              name = type.description
            }
          }
          else {
            name = type.description
          }
        case .revokeSponsorship:
          let revokeSponsorshipOperation = try? stellarsdk.Operation.fromXDR(operationXDR: operation) as? RevokeSponsorshipOperation
          do {
            guard let revokeSponsorshipOperation = revokeSponsorshipOperation else {
              name = type.description
              return operationNames
            }
            
            if let ledgerKey = revokeSponsorshipOperation.ledgerKey {
              switch ledgerKey {
              case .account:
                name = "Revoke Account Sponsorship"
              case .claimableBalance:
                name = "Revoke Claimable Balance Sponsorship"
              case .data:
                name = "Revoke Data Sponsorship"
              case .offer:
                name = "Revoke Offer Sponsorship"
              case .trustline:
                name = "Revoke Trustline Sponsorship"
              case .liquidityPool:
                name = ""
              }
            } else {
              name = "Revoke Signer Sponsorship"
            }
          }
        default:
          name = type.description
        }
        operationNames.append(name)
      }
    }
    
    return operationNames
  }
  
  static func getOperation(from xdr: String, by index: Int = 0) throws -> stellarsdk.Operation {
    
    guard let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard transactionXDR.txOperations.count > index else {
      throw VaultError.TransactionError.outOfOperationRange
    }
    
    let operationXDR = transactionXDR.txOperations[index]
    
    guard let operation = try? Operation.fromXDR(operationXDR: operationXDR) else {
      throw VaultError.OperationError.invalidOperation
    }
    
    return operation
  }
  
  static func getPublicKeys(from operation: stellarsdk.Operation) -> [String] {
    var publicKeys: [String] = []
    
    switch type(of: operation) {
    case is PaymentOperation.Type:
      let paymentOperation = operation as! PaymentOperation
      publicKeys.append(paymentOperation.destinationAccountId)
      if let issuer = paymentOperation.asset.issuer?.accountId, paymentOperation.asset.code != nil {
        publicKeys.append(issuer)
      }
      if let operationSourceAccountId = paymentOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is CreateAccountOperation.Type:
      let createAccountOperation = operation as! CreateAccountOperation
      publicKeys.append(createAccountOperation.destination.accountId)
      if let operationSourceAccountId = createAccountOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is PathPaymentOperation.Type:
      let pathPaymentOperation = operation as! PathPaymentOperation

      if let sendIssuer = pathPaymentOperation.sendAsset.issuer?.accountId, pathPaymentOperation.sendAsset.code != nil {
        publicKeys.append(sendIssuer)
      }
      
      publicKeys.append(pathPaymentOperation.destinationAccountId)
      
      if let destIssuer = pathPaymentOperation.destAsset.issuer?.accountId, pathPaymentOperation.destAsset.code != nil {
        publicKeys.append(destIssuer)
      }
      
      if let operationSourceAccountId = pathPaymentOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is ManageOfferOperation.Type:
      let manageOfferOperation = operation as! ManageOfferOperation
      
      if let sellIssuer = manageOfferOperation.selling.issuer?.accountId, manageOfferOperation.selling.code != nil {
        publicKeys.append(sellIssuer)
      }
      
      if let buyIssuer = manageOfferOperation.buying.issuer?.accountId, manageOfferOperation.buying.code != nil {
        publicKeys.append(buyIssuer)
      }
      if let operationSourceAccountId = manageOfferOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is CreatePassiveOfferOperation.Type:
      let createPassiveOfferOperation = operation as! CreatePassiveOfferOperation
      if let sellIssuer = createPassiveOfferOperation.selling.issuer?.accountId, createPassiveOfferOperation.selling.code != nil {
        publicKeys.append(sellIssuer)
      }
      if let buyIssuer = createPassiveOfferOperation.buying.issuer?.accountId, createPassiveOfferOperation.buying.code != nil {
        publicKeys.append(buyIssuer)
      }

      if let operationSourceAccountId = createPassiveOfferOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is SetOptionsOperation.Type:
      let setOptionsOperation = operation as! SetOptionsOperation
      if let x = setOptionsOperation.signer?.xdrEncoded, let s = try? PublicKey(xdr: x).accountId {
        publicKeys.append(s)
      }
      if let operationSourceAccountId = setOptionsOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    // Set Flags / Clear Flags
    case is AllowTrustOperation.Type:
      let allowTrustOperation = operation as! AllowTrustOperation
      publicKeys.append(allowTrustOperation.trustor.accountId)
      if let operationSourceAccountId = allowTrustOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is ChangeTrustOperation.Type:
      let changeTrustOperation = operation as! ChangeTrustOperation
      if let issuer = changeTrustOperation.asset.issuer?.accountId {
        publicKeys.append(issuer)
      }
      if let issuerA = changeTrustOperation.asset.assetA?.issuer?.accountId {
        publicKeys.append(issuerA)
      }
      if let issuerB = changeTrustOperation.asset.assetB?.issuer?.accountId {
        publicKeys.append(issuerB)
      }
      if let operationSourceAccountId = changeTrustOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is AccountMergeOperation.Type:
      let accountMergeOperation = operation as! AccountMergeOperation
      publicKeys.append(accountMergeOperation.destinationAccountId)
      if let operationSourceAccountId = accountMergeOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is ManageDataOperation.Type:
      let manageDataOperation = operation as! ManageDataOperation
      if let operationSourceAccountId = manageDataOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is BumpSequenceOperation.Type:
      let bumpSequenceOperation = operation as! BumpSequenceOperation
      if let operationSourceAccountId = bumpSequenceOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is BeginSponsoringFutureReservesOperation.Type:
      let beginSponsoringFutureReservesOperation = operation as! BeginSponsoringFutureReservesOperation
      publicKeys.append(beginSponsoringFutureReservesOperation.sponsoredId)
      if let operationSourceAccountId = beginSponsoringFutureReservesOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is EndSponsoringFutureReservesOperation.Type:
      let endSponsoringFutureReservesOperation = operation as! EndSponsoringFutureReservesOperation
      if let operationSourceAccountId = endSponsoringFutureReservesOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is CreateClaimableBalanceOperation.Type:
      let createClaimableBalanceOperation = operation as! CreateClaimableBalanceOperation
      
      if createClaimableBalanceOperation.claimants.count > 1 {
        for claimant in createClaimableBalanceOperation.claimants {
          publicKeys.append(claimant.destination)
        }
      } else {
        if let claimant = createClaimableBalanceOperation.claimants.first {
          publicKeys.append(claimant.destination)
        }
      }
      
      if let operationSourceAccountId = createClaimableBalanceOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is ClawbackOperation.Type:
      let clawbackOperation = operation as! ClawbackOperation
      publicKeys.append(clawbackOperation.fromAccountId)
      
      if let issuer = clawbackOperation.asset.issuer?.accountId {
        publicKeys.append(issuer)
      }
      
      if let operationSourceAccountId = clawbackOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is RevokeSponsorshipOperation.Type:
      let revokeSponsorshipOperation = operation as! RevokeSponsorshipOperation
      
      if let ledgerKey = revokeSponsorshipOperation.ledgerKey {
        switch ledgerKey {
        case .account(let ledgerKey):
          publicKeys.append(ledgerKey.accountID.accountId)
          
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId {
            publicKeys.append(operationSourceAccountId)
          }
        case .claimableBalance:
          break
        case .data(let ledgerKey):
          publicKeys.append(ledgerKey.accountId.accountId)
        case .offer(let ledgerKey):
          publicKeys.append(ledgerKey.sellerId.accountId)
        case .trustline(let ledgerKey):
          publicKeys.append(ledgerKey.accountID.accountId)
          if let issuer = ledgerKey.asset.issuer?.accountId {
            publicKeys.append(issuer)
          }
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId {
            publicKeys.append(operationSourceAccountId)
          }
          
        case .liquidityPool:
          break
        }
      } else {
        if let accountId = revokeSponsorshipOperation.signerAccountId {
          publicKeys.append(accountId)
        }
        if let x = revokeSponsorshipOperation.signerKey.xdrEncoded, let s = try? PublicKey(xdr: x).accountId {
          publicKeys.append(s)
        }
        if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId {
          publicKeys.append(operationSourceAccountId)
        }
      }
    case is SetTrustlineFlagsOperation.Type:
      let setTrustlineFlagsOperation = operation as! SetTrustlineFlagsOperation
      publicKeys.append(setTrustlineFlagsOperation.trustorAccountId)
      if let issuer = setTrustlineFlagsOperation.asset.issuer?.accountId {
        publicKeys.append(issuer)
      }
      
      if let operationSourceAccountId = setTrustlineFlagsOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is LiquidityPoolDepositOperation.Type:
      let liquidityPoolDepositOperation = operation as! LiquidityPoolDepositOperation
      if let operationSourceAccountId = liquidityPoolDepositOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is LiquidityPoolWithdrawOperation.Type:
      let liquidityPoolWithdrawOperation = operation as! LiquidityPoolWithdrawOperation
      if let operationSourceAccountId = liquidityPoolWithdrawOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    default:
      break
    }
    
    return publicKeys
  }
  
  static func getAssets(from operation: stellarsdk.Operation) -> [stellarsdk.Asset] {
    var assets: [stellarsdk.Asset] = []
    
    switch type(of: operation) {
    case is PaymentOperation.Type:
      let paymentOperation = operation as! PaymentOperation
      assets.append((paymentOperation.asset))
    case is CreateAccountOperation.Type:
      if let nativeAsset = stellarsdk.Asset(canonicalForm: "XLM") {
        assets.append(nativeAsset)
      }
    case is PathPaymentOperation.Type:
      let pathPaymentOperation = operation as! PathPaymentOperation
      assets.append(pathPaymentOperation.sendAsset)
      assets.append(pathPaymentOperation.destAsset)
    case is ManageOfferOperation.Type:
      let manageOfferOperation = operation as! ManageOfferOperation
      assets.append(manageOfferOperation.selling)
      assets.append(manageOfferOperation.buying)
    case is CreatePassiveOfferOperation.Type:
      let createPassiveOfferOperation = operation as! CreatePassiveOfferOperation
      assets.append(createPassiveOfferOperation.selling)
      assets.append(createPassiveOfferOperation.buying)
    case is AllowTrustOperation.Type:
      let allowTrustOperation = operation as! AllowTrustOperation
      let asset = stellarsdk.Asset(type: 0, code: allowTrustOperation.assetCode, issuer: allowTrustOperation.trustor)
      if let asset = asset {
        assets.append(asset)
      }
    case is ChangeTrustOperation.Type:
      let changeTrustOperation = operation as! ChangeTrustOperation
      assets.append(changeTrustOperation.asset)
      if let assetA = changeTrustOperation.asset.assetA {
        assets.append(assetA)
      }
      if let assetB = changeTrustOperation.asset.assetB {
        assets.append(assetB)
      }
    case is CreateClaimableBalanceOperation.Type:
      let createClaimableBalanceOperation = operation as! CreateClaimableBalanceOperation
      assets.append(createClaimableBalanceOperation.asset)
    case is ClawbackOperation.Type:
      let clawbackOperation = operation as! ClawbackOperation
      assets.append(clawbackOperation.asset)
    case is RevokeSponsorshipOperation.Type:
      let revokeSponsorshipOperation = operation as! RevokeSponsorshipOperation
      if let ledgerKey = revokeSponsorshipOperation.ledgerKey {
        switch ledgerKey {
        case .trustline(let ledgerKey):
          if let publicKey = ledgerKey.asset.issuer {
            if let asset = stellarsdk.Asset.init(type: ledgerKey.asset.type(), code: ledgerKey.asset.assetCode, issuer: KeyPair.init(publicKey: publicKey)) {
              assets.append(asset)
            }
          }
        default: break
        }
      }
    case is SetTrustlineFlagsOperation.Type:
      let setTrustlineFlagsOperation = operation as! SetTrustlineFlagsOperation
      assets.append(setTrustlineFlagsOperation.asset)
    default:
      break
    }
  
    return assets
  }
  
  static func parseOperation(from operation: stellarsdk.Operation, transactionSourceAccountId: String, memo: String?, isListOperations: Bool = false, destinationFederation: String = "") -> [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)] {
    var data: [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)] = []
    
    switch type(of: operation) {
    case is PaymentOperation.Type:
      let paymentOperation = operation as! PaymentOperation
      data.append(("Destination", paymentOperation.destinationAccountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: paymentOperation.destinationAccountId), true, false))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Asset", paymentOperation.asset.code ?? "XLM", "", false, true))
      data.append(("Amount", paymentOperation.amount.formattedString, "", false, false))
      if let issuer = paymentOperation.asset.issuer?.accountId, paymentOperation.asset.code != nil {
        data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
      }
      if let memo = memo, !memo.isEmpty {
        data.append(("Memo", memo, "", false, false))
      }
      if let operationSourceAccountId = paymentOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is CreateAccountOperation.Type:
      let createAccountOperation = operation as! CreateAccountOperation
      data.append(("Destination", createAccountOperation.destination.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: createAccountOperation.destination.accountId), true, false))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Asset", "XLM", "" , false, true))
      data.append(("Starting Balance", createAccountOperation.startBalance.formattedString, "", false, false))
      if let operationSourceAccountId = createAccountOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is PathPaymentOperation.Type:
      let pathPaymentOperation = operation as! PathPaymentOperation
      data.append(("Destination", pathPaymentOperation.destinationAccountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: pathPaymentOperation.destinationAccountId), true, false))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Send Asset", pathPaymentOperation.sendAsset.code ?? "XLM", "", false, true))
      if let sendIssuer = pathPaymentOperation.sendAsset.issuer?.accountId, pathPaymentOperation.sendAsset.code != nil {
        data.append(("Asset Issuer", sendIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: sendIssuer), true, false))
      }
      data.append((getPathPaymentFieldTitle(pathPaymentOperation: pathPaymentOperation, isSend: true), pathPaymentOperation.sendMax.formattedString, "", false, false))
      data.append(("Receive Asset", pathPaymentOperation.destAsset.code ?? "XLM", "", false, true))
      if let destIssuer = pathPaymentOperation.destAsset.issuer?.accountId, pathPaymentOperation.destAsset.code != nil {
        data.append(("Asset Issuer", destIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: destIssuer), true, false))
      }
      data.append((getPathPaymentFieldTitle(pathPaymentOperation: pathPaymentOperation, isSend: false), pathPaymentOperation.destAmount.formattedString, "", false, false))
      if let operationSourceAccountId = pathPaymentOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is ManageOfferOperation.Type:
      let manageOfferOperation = operation as! ManageOfferOperation
      if manageOfferOperation.offerId != 0 {
        data.append(("Offer ID", manageOfferOperation.offerId.description, "", false, false))
      }
      
      if let operationXdr = try? manageOfferOperation.toXDR() {
        let operationTypeValue = operationXdr.body.type()
        let operationType = OperationType(rawValue: operationTypeValue)
        
        if let type = operationType {
          switch type {
          case .manageBuyOffer:
            data.append(("Buying", manageOfferOperation.buying.code ?? "XLM", "", false, true))
            if let buyIssuer = manageOfferOperation.buying.issuer?.accountId, manageOfferOperation.buying.code != nil {
              data.append(("Asset Issuer", buyIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: buyIssuer), true, false))
            }
            if manageOfferOperation.amount != 0 {
              data.append(("Amount", manageOfferOperation.amount.formattedString, "", false, false))
            }
            data.append(("Selling", manageOfferOperation.selling.code ?? "XLM", "", false, true))
            if let sellIssuer = manageOfferOperation.selling.issuer?.accountId, manageOfferOperation.selling.code != nil {
              data.append(("Asset Issuer", sellIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: sellIssuer), true, false))
            }
            data.append(("Price", manageOfferOperation.price.formattedString, "", false, false))
            if manageOfferOperation.amount != 0 {
              data.append(("Total", getTotalPrice(for: manageOfferOperation.price, amount: manageOfferOperation.amount), "", false, false))
            }
          case .manageSellOffer:
            data.append(("Selling", manageOfferOperation.selling.code ?? "XLM", "", false, true))
            if let sellIssuer = manageOfferOperation.selling.issuer?.accountId, manageOfferOperation.selling.code != nil {
              data.append(("Asset Issuer", sellIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: sellIssuer), true, false))
            }
            if manageOfferOperation.amount != 0 {
              data.append(("Amount", manageOfferOperation.amount.formattedString, "", false, false))
            }
            data.append(("Buying", manageOfferOperation.buying.code ?? "XLM", "", false, true))
            if let buyIssuer = manageOfferOperation.buying.issuer?.accountId, manageOfferOperation.buying.code != nil {
              data.append(("Asset Issuer", buyIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: buyIssuer), true, false))
            }
            data.append(("Price", manageOfferOperation.price.formattedString, "", false, false))
            if manageOfferOperation.amount != 0 {
              data.append(("Total", getTotalPrice(for: manageOfferOperation.price, amount: manageOfferOperation.amount), "", false, false))
            }
          default: break
          }
        }
      }
      if let operationSourceAccountId = manageOfferOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is CreatePassiveOfferOperation.Type:
      let createPassiveOfferOperation = operation as! CreatePassiveOfferOperation
      data.append(("Selling", createPassiveOfferOperation.selling.code ?? "XLM", "", false, true))
      if let sellIssuer = createPassiveOfferOperation.selling.issuer?.accountId, createPassiveOfferOperation.selling.code != nil {
        data.append(("Asset Issuer", sellIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: sellIssuer), true, false))
      }
      data.append(("Buying", createPassiveOfferOperation.buying.code ?? "XLM", "", false, true))
      if let buyIssuer = createPassiveOfferOperation.buying.issuer?.accountId, createPassiveOfferOperation.buying.code != nil {
        data.append(("Asset Issuer", buyIssuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: buyIssuer), true, false))
      }
      data.append(("Amount", createPassiveOfferOperation.amount.formattedString, "", false, false))
      data.append(("Price", createPassiveOfferOperation.price.formattedString, "", false, false))
      if let operationSourceAccountId = createPassiveOfferOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is SetOptionsOperation.Type:
      let setOptionsOperation = operation as! SetOptionsOperation
      if let homeDomain = setOptionsOperation.homeDomain {
        data.append(("Home Domain", homeDomain, "", false, false))
      }
      if let masterKeyWeight = setOptionsOperation.masterKeyWeight {
        data.append(("Master Weight", masterKeyWeight.description, "", false, false))
      }
      if let lowThreshold = setOptionsOperation.lowThreshold {
        data.append(("Low Threshold", lowThreshold.description, "", false, false))
      }
      if let mediumThreshold = setOptionsOperation.mediumThreshold {
        data.append(("Medium Threshold", mediumThreshold.description, "", false, false))
      }
      if let highThreshold = setOptionsOperation.highThreshold {
        data.append(("High Threshold", highThreshold.description, "", false, false))
      }
      if let signerWeight = setOptionsOperation.signerWeight {
        data.append(("Signer Weight", signerWeight.description, "", false, false))
      }
      if let x = setOptionsOperation.signer?.xdrEncoded, let s = try? PublicKey(xdr: x).accountId {
        data.append(("Signer Key", s.getTruncatedPublicKey(), tryToGetNickname(publicKey: s), true, false))
      }
      if let operationSourceAccountId = setOptionsOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    // Set Flags / Clear Flags
    case is AllowTrustOperation.Type:
      let allowTrustOperation = operation as! AllowTrustOperation
      data.append(("Asset", allowTrustOperation.assetCode, "", false, true))
      data.append(("Trustor", allowTrustOperation.trustor.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: allowTrustOperation.trustor.accountId), true, false))
      data.append(("Authorize", allowTrustOperation.authorize.description, "", false, false))
      if let operationSourceAccountId = allowTrustOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is ChangeTrustOperation.Type:
      let changeTrustOperation = operation as! ChangeTrustOperation
      if let assetCode = changeTrustOperation.asset.code {
        data.append(("Asset", assetCode, "", false, true))
      }
      if let issuer = changeTrustOperation.asset.issuer?.accountId {
        data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
      }
      if let assetA = changeTrustOperation.asset.assetA {
        data.append(("Asset A", assetA.code ?? "XLM", "", false, true))
        if let issuer = assetA.issuer?.accountId {
          data.append(("Asset A Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
        }
      }
      if let assetB = changeTrustOperation.asset.assetB {
        data.append(("Asset B", assetB.code ?? "XLM", "", false, true))
        if let issuer = assetB.issuer?.accountId {
          data.append(("Asset B Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
        }
      }
  
      let changeTrustAssetXDR = try? changeTrustOperation.asset.toChangeTrustAssetXDR()
      switch changeTrustAssetXDR {
      case .poolShare(let liquidityPoolParametersXDR):
        switch liquidityPoolParametersXDR {
        case .constantProduct(let liquidityPoolConstantProductParametersXDR):
          data.append(("Fee", liquidityPoolConstantProductParametersXDR.fee.description, "", false, false))
        }
      default: break
      }
      
      if let limit = changeTrustOperation.limit {
        data.append(("Limit", limit.formattedString, "", false, false))
      }
      if let operationSourceAccountId = changeTrustOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is AccountMergeOperation.Type:
      let accountMergeOperation = operation as! AccountMergeOperation
      data.append(("Destination", accountMergeOperation.destinationAccountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: accountMergeOperation.destinationAccountId), true, false))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      if let operationSourceAccountId = accountMergeOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is ManageDataOperation.Type:
      let manageDataOperation = operation as! ManageDataOperation
      data.append(("Name", manageDataOperation.name, "", false, false))
      if let value = manageDataOperation.data {
        data.append(("Value", value.toUtf8String() ?? "none", "", false, false))
      }
      if let operationSourceAccountId = manageDataOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is BumpSequenceOperation.Type:
      let bumpSequenceOperation = operation as! BumpSequenceOperation
      data.append(("Bump To", bumpSequenceOperation.bumpTo.description, "", false, false))
      if let operationSourceAccountId = bumpSequenceOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is BeginSponsoringFutureReservesOperation.Type:
      let beginSponsoringFutureReservesOperation = operation as! BeginSponsoringFutureReservesOperation
      data.append(("Sponsored ID", beginSponsoringFutureReservesOperation.sponsoredId.getTruncatedPublicKey(), tryToGetNickname(publicKey: beginSponsoringFutureReservesOperation.sponsoredId), true, false))
      if let operationSourceAccountId = beginSponsoringFutureReservesOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is EndSponsoringFutureReservesOperation.Type:
      let endSponsoringFutureReservesOperation = operation as! EndSponsoringFutureReservesOperation
      if let operationSourceAccountId = endSponsoringFutureReservesOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is CreateClaimableBalanceOperation.Type:
      let createClaimableBalanceOperation = operation as! CreateClaimableBalanceOperation
      data.append(("Amount", createClaimableBalanceOperation.amount.formattedString, "", false, false))
      data.append(("Asset", createClaimableBalanceOperation.asset.code ?? "XLM", "", false, true))
      
      if createClaimableBalanceOperation.claimants.count > 1 {
        var number = 0
        for claimant in createClaimableBalanceOperation.claimants {
          number += 1
          data.append(("Claimant \(number)", claimant.destination.getTruncatedPublicKey(), tryToGetNickname(publicKey: claimant.destination), true, false))
        }
      } else {
        if let claimant = createClaimableBalanceOperation.claimants.first {
          data.append(("Claimant", claimant.destination.getTruncatedPublicKey(), tryToGetNickname(publicKey: claimant.destination), true, false))
        }
      }
      if let operationSourceAccountId = createClaimableBalanceOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is ClaimClaimableBalanceOperation.Type:
      let claimClaimableBalanceOperation = operation as! ClaimClaimableBalanceOperation
      data.append(("Balance ID", claimClaimableBalanceOperation.balanceId.getMiddleTruncated(), "", false, false))
      if let operationSourceAccountId = claimClaimableBalanceOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is ClawbackOperation.Type:
      let clawbackOperation = operation as! ClawbackOperation
      data.append(("From", clawbackOperation.fromAccountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: clawbackOperation.fromAccountId), true, false))
      if let assetCode = clawbackOperation.asset.code {
        data.append(("Asset", assetCode, "", false, true))
      }
      if let issuer = clawbackOperation.asset.issuer?.accountId {
        data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
      }
      data.append(("Amount", clawbackOperation.amount.formattedString, "", false, false))
      if let operationSourceAccountId = clawbackOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is ClawbackClaimableBalanceOperation.Type:
      let clawbackClaimableBalanceOperation = operation as! ClawbackClaimableBalanceOperation
      data.append(("Balance ID", clawbackClaimableBalanceOperation.claimableBalanceID.getMiddleTruncated(), "", false, false))
      if let operationSourceAccountId = clawbackClaimableBalanceOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is RevokeSponsorshipOperation.Type:
      let revokeSponsorshipOperation = operation as! RevokeSponsorshipOperation
      
      if let ledgerKey = revokeSponsorshipOperation.ledgerKey {
        switch ledgerKey {
        case .account(let ledgerKey):
          data.append(("Account ID", ledgerKey.accountID.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: ledgerKey.accountID.accountId), true, false))
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
            data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
          }
        case .claimableBalance(let ledgerKey):
          let claimClaimableBalanceOpXDR = ClaimClaimableBalanceOpXDR(balanceID: ledgerKey)
          do {
            let claimClaimableBalanceOperation = try ClaimClaimableBalanceOperation(fromXDR: claimClaimableBalanceOpXDR, sourceAccountId: transactionSourceAccountId)
            data.append(("Balance ID", claimClaimableBalanceOperation.balanceId.getMiddleTruncated(), "", false, false))
          } catch {
            break
          }
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
            data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
          }
        case .data(let ledgerKey):
          // need public
          data.append(("Account ID", ledgerKey.accountId.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: ledgerKey.accountId.accountId), true, false))
          data.append(("Data Name", ledgerKey.dataName, "", false, false))
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
            data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
          }
        case .offer(let ledgerKey):
          // need public
          data.append(("Seller", ledgerKey.sellerId.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: ledgerKey.sellerId.accountId), true, false))
          data.append(("Offer ID", ledgerKey.offerId.description, "", false, false))
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
            data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
          }
        case .trustline(let ledgerKey):
          data.append(("Account ID", ledgerKey.accountID.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: ledgerKey.accountID.accountId), true, false))
          if let assetCode = ledgerKey.asset.assetCode {
            data.append(("Asset", assetCode, "", false, true))
          }
          if let issuer = ledgerKey.asset.issuer?.accountId {
            data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
          }
          if let poolId = ledgerKey.asset.poolId {
            data.append(("Liquidity Pool ID", poolId.getMiddleTruncated(), "", false, false))
          }
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
            data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
          }
          
        case .liquidityPool(let ledgerKey):
          data.append(("Liquidity Pool ID", ledgerKey.poolIDString.getMiddleTruncated(), "", false, false))
          if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
            data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
          }
        }
      } else {
        if let accountId = revokeSponsorshipOperation.signerAccountId {
          data.append(("Account ID", accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: accountId), true, false))
        }
        
        if let x = revokeSponsorshipOperation.signerKey.xdrEncoded, let s = try? PublicKey(xdr: x).accountId {
          data.append(("Signer Public Key", s.getTruncatedPublicKey(), tryToGetNickname(publicKey: s), true, false))
        }
        
        if let operationSourceAccountId = revokeSponsorshipOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
          data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
        }
      }
    case is SetTrustlineFlagsOperation.Type:
      let setTrustlineFlagsOperation = operation as! SetTrustlineFlagsOperation
      data.append(("Trustor", setTrustlineFlagsOperation.trustorAccountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: setTrustlineFlagsOperation.trustorAccountId), true, false))
      if let assetCode = setTrustlineFlagsOperation.asset.code {
        data.append(("Asset", assetCode, "", false, true))
      }
      if let issuer = setTrustlineFlagsOperation.asset.issuer?.accountId {
        data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
      }
      let clearFlags = mapFlags(flags: setTrustlineFlagsOperation.clearFlags)
      if !clearFlags.isEmpty {
        data.append(("Clear Flags", clearFlags, "", false, false))
      }
      let setFlags = mapFlags(flags: setTrustlineFlagsOperation.setFlags)
      if !setFlags.isEmpty {
        data.append(("Set Flags", setFlags, "", false, false))
      }
      if let operationSourceAccountId = setTrustlineFlagsOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is LiquidityPoolDepositOperation.Type:
      let liquidityPoolDepositOperation = operation as! LiquidityPoolDepositOperation
      data.append(("Liquidity Pool ID", liquidityPoolDepositOperation.liquidityPoolId.getMiddleTruncated(), "", false, false))
      data.append(("Max Amount A", liquidityPoolDepositOperation.maxAmountA.formattedString, "", false, false))
      data.append(("Max Amount B", liquidityPoolDepositOperation.maxAmountB.formattedString, "", false, false))
      data.append(("Min Price", liquidityPoolDepositOperation.minPrice.formattedString, "", false, false))
      data.append(("Max Price", liquidityPoolDepositOperation.maxPrice.formattedString, "", false, false))
      if let operationSourceAccountId = liquidityPoolDepositOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is LiquidityPoolWithdrawOperation.Type:
      let liquidityPoolWithdrawOperation = operation as! LiquidityPoolWithdrawOperation
      data.append(("Liquidity Pool ID", liquidityPoolWithdrawOperation.liquidityPoolId.getMiddleTruncated(), "", false, false))
      data.append(("Amount", liquidityPoolWithdrawOperation.amount.formattedString, "", false, false))
      data.append(("Min Amount A", liquidityPoolWithdrawOperation.minAmountA.formattedString, "", false, false))
      data.append(("Min Amount B", liquidityPoolWithdrawOperation.minAmountB.formattedString, "", false, false))
      if let operationSourceAccountId = liquidityPoolWithdrawOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    default:
      break
    }
    
    return data
  }
  
  static func getPathPaymentFieldTitle(pathPaymentOperation: PathPaymentOperation, isSend: Bool) -> String {
    if let operationXdr = try? pathPaymentOperation.toXDR() {
      let operationTypeValue = operationXdr.body.type()
      let operationType = OperationType(rawValue: operationTypeValue)
      
      if let type = operationType {
        switch type {
        case .pathPaymentStrictSend:
          let title = isSend ? "Send Amount" : "Receive Min"
          return title
        case .pathPayment:
          let title = isSend ? "Send Max" : "Receive Amount"
          return title
        default: break
        }
      }
    }
    return ""
  }
  
  static func tryToGetNickname(publicKey: String) -> String {
    storageAccounts = storage.retrieveAccounts() ?? []
    
    if let account = storageAccounts.first(where: { $0.address == publicKey }) {
      if let nickName = account.nickname, !nickName.isEmpty {
        return nickName
      } else {
        return ""
      }
    } else {
      return ""
    }
  }
  
  static func tryToSetDestinationFederation(data: inout [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)], destinationFederation: String) {
    if !destinationFederation.isEmpty {
      data.append(("Destination Federation", destinationFederation, "", false, false))
    }
  }
  
  static func tryToSetOperationFields(data: inout [(name: String, value: String, isAssetCode: Bool)], transactionSourceAccountId: String, created: String?, isListOperations: Bool = false) {
//    if !isListOperations {
//      data.append(("Transaction Source", transactionSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), false))
//    }
//    if let created = created, !created.isEmpty {
//      data.append(("Created", created, false))
//    }
  }
  
  static func getTotalPrice(for price: Price, amount: Decimal) -> String {
    let priceValue = Double(price.n) / Double(price.d)
    let amountValue = NSDecimalNumber(decimal: amount).doubleValue
    let totalValue = priceValue * amountValue
    let totalString = totalValue.formattedString
    return totalString
  }
  
  static func getNumberOfCharactersForTruncatePublicKeyTransactionList() -> Int {
    switch UIDevice().type {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
      return 3
    default:
      return 6
    }
  }
  
  static func getNumberOfCharactersForTruncatePublicKeyTransactionDetails() -> Int {
    switch UIDevice().type {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
      return 4
    default:
      return 8
    }
  }
  
  static func getOutputDateFormat(from sourceDate: String) -> String {
    let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
    var outputDateFormat = ""
    let locale = NSLocale.current
    let formatter : String? = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)
    
    switch UIDevice().type {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
      let dateFormatterGet = DateFormatter()
      dateFormatterGet.dateFormat = inputDateFormat
      dateFormatterGet.locale = Locale(identifier: "en_US")
      
      if let date = dateFormatterGet.date(from: sourceDate) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: currentDate)
        let year = components.year
        if let year = year, yearString == String(year) {
          if let formatter = formatter, formatter.contains("a") {
            outputDateFormat = "MMM d hh:mm a"
          } else {
            outputDateFormat = "MMM d HH:mm"
          }
        }
        else {
          outputDateFormat = "MMM d yyyy"
        }
      }
    default:
      if let formatter = formatter, formatter.contains("a") {
        outputDateFormat = "MMM d yyyy hh:mm a"
      } else {
        outputDateFormat = "MMM d yyyy HH:mm"
      }
    }
    return outputDateFormat
  }
  
  static func getValidatedDateForList(from sourceDate: String) -> String {
    let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
    let outputDateFormat = getOutputDateFormat(from: sourceDate)
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = inputDateFormat
    dateFormatterGet.locale = Locale(identifier: "en_US")
    
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = outputDateFormat
    dateFormatterPrint.amSymbol = "AM"
    dateFormatterPrint.pmSymbol = "PM"
    
    if let date = dateFormatterGet.date(from: sourceDate) {
      return dateFormatterPrint.string(from: date)
    } else {
      return "none"
    }
    
  }

  
  static func getValidatedDate(from sourceDate: String) -> String {
    let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
    var outputDateFormat = "MMM d yyyy hh:mm a"
    let locale = NSLocale.current
    let formatter : String? = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)
    if let formatter = formatter, formatter.contains("a") {
      outputDateFormat = "MMM d yyyy hh:mm a"
    } else {
      outputDateFormat = "MMM d yyyy HH:mm"
    }
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = inputDateFormat
    dateFormatterGet.locale = Locale(identifier: "en_US")
    
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = outputDateFormat
    dateFormatterPrint.amSymbol = "AM"
    dateFormatterPrint.pmSymbol = "PM"
    
    if let date = dateFormatterGet.date(from: sourceDate) {
      return dateFormatterPrint.string(from: date)
    } else {
      return "none"
    }
  }
  
  static func getTransactionResult(from message: String) throws ->
    (resultCode: TransactionResultCode, operaiotnMessageError: String?) {
      
    guard let errorMessage = try? JSONDecoder().decode(HorizonErrorMessage.self,
                                                       from: message.data(using: String.Encoding.utf8)!) else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard let resultXDR = errorMessage.extras?.result_xdr else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard let transactionResultXDR = try? TransactionResultXDR(xdr: resultXDR) else {
      throw VaultError.TransactionError.invalidTransaction
    }
      
    var operationMessageError: String? = nil
    if let resultBody = transactionResultXDR.resultBody {
      operationMessageError = tryToGetOperationErrorMessage(from: resultBody)
    }
    
    return (transactionResultXDR.code, operationMessageError)
  }
  
  static func tryToGetOperationErrorMessage(from resultBody: TransactionResultBodyXDR) -> String? {
    switch resultBody {
    case .success(let operations):
      guard let operation = operations.first else { break }
      switch operation {
      case .payment(_, let paymentResult):
        switch paymentResult {
        case .empty(let errorCode):
          return PaymentResultCode.underfunded.rawValue == errorCode ? "Not enough funds" : nil
        default: break
        }
      case .createAccount(_, let createAccountResult):
        switch createAccountResult {
        case .empty(let errorCode):
          return CreateAccountResultCode.underfunded.rawValue == errorCode ? "Not enough funds" : nil
        default: break
        }
      case .manageBuyOffer(_, let manageOfferResult), .manageSellOffer(_, let manageOfferResult):
        switch manageOfferResult {
        case .empty(let errorCode):
          return ManageOfferResultCode.underfunded.rawValue == errorCode ? "Not enough funds" : nil
        default: break
        }
      case .empty(let errorCode):
        if errorCode == OperationResultCode.tooManySubentries.rawValue {
          return L10n.errorTooManySubentriesMessage
        }
      default: break
      }
    default: break
    }
    
    return nil
  }
  
  // account id finding logic for non-funded source account
  static func getAccountId(signedAccounts: [SignedAccount], transactionEnvelopeXDR: TransactionEnvelopeXDR) -> String {
    var accountId = ""
    if signedAccounts.contains(where: { $0.address == transactionEnvelopeXDR.txSourceAccountId }) {
      accountId = signedAccounts.first(where: { $0.address == transactionEnvelopeXDR.txSourceAccountId })?.address ?? ""
    } else {
      for operation in transactionEnvelopeXDR.txOperations {
        if signedAccounts.contains(where: { $0.address == operation.sourceAccount?.accountId }) {
          accountId = signedAccounts.first(where: { $0.address == operation.sourceAccount?.accountId })?.address ?? ""
          return accountId
        } else {
          accountId = transactionEnvelopeXDR.txSourceAccountId
        }
      }
    }
    return accountId
  }
  
  static func getManageDataOperationAuthEndpointWithPrefix(from xdr: String) -> String {
    let domain = TransactionHelper.getManageDataOperationAuthEndpoint(from: xdr)
    let prefix = "https://"
    if domain.hasPrefix(prefix) {
      return domain
    } else {
      return prefix + domain
    }
  }
  
  static func getManageDataOperationDomain(from xdr: String) -> String {
    let operation = try? TransactionHelper.getOperation(from: xdr)
    var domain = ""
    if let operation = operation {
      switch type(of: operation) {
      case is ManageDataOperation.Type:
        let manageDataOperation = operation as! ManageDataOperation
        domain = manageDataOperation.name
      default: break
      }
    }
    return getTruncatedDomain(domain: &domain)
  }
  
  static func getManageDataOperationAuthEndpoint(from xdr: String) -> String {
    var domain = ""
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      return ""
    }
    
    for operationXDR in transactionEnvelopeXDR.txOperations {
      guard let operation = try? Operation.fromXDR(operationXDR: operationXDR) else {
        return ""
      }
      
      switch type(of: operation) {
      case is ManageDataOperation.Type:
        let manageDataOperation = operation as! ManageDataOperation
        if manageDataOperation.name == "web_auth_domain" {
          if let data = manageDataOperation.data {
            domain = String(decoding: data, as: UTF8.self)
            return domain
          }
        } else {
          domain = ""
        }
      default: break
      }
    }
    return domain
  }
  
  static func getClientDomainAccount(from xdr: String) -> String {
    var clientDomainAccount = ""
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      return ""
    }
    
    for operationXDR in transactionEnvelopeXDR.txOperations {
      guard let operation = try? Operation.fromXDR(operationXDR: operationXDR) else {
        return ""
      }
      
      switch type(of: operation) {
      case is ManageDataOperation.Type:
        let manageDataOperation = operation as! ManageDataOperation
        if manageDataOperation.name == "client_domain" {
          if let accountId = manageDataOperation.sourceAccountId {
            clientDomainAccount = accountId
            return clientDomainAccount
          }
        } else {
          clientDomainAccount = ""
        }
      default: break
      }
    }
    return clientDomainAccount
  }
  
  static func getTruncatedDomain(domain: inout String) -> String {
    if let range = domain.range(of: " auth") {
      domain.removeSubrange(range)
    }
    return domain
  }
  
  static func getTrancatedClaimantsWithSeparator(claimants: [Claimant]) -> String {
    var claimantsFullString = ""
    var claimantsTruncatedFullString = ""
    
    for claimant in claimants {
      claimantsFullString += claimant.destination
    }
    
    let claimantsFullStringArray = claimantsFullString.split(by: 56)
    
    for claimantString in claimantsFullStringArray {
      let claimantTruncatedString = claimantString.getTruncatedPublicKey()
      claimantsTruncatedFullString += claimantTruncatedString
    }
    
    let truncatedClaimantsWithSeparator = claimantsTruncatedFullString.inserting(separator: "\n", every: 19)
    
    return truncatedClaimantsWithSeparator
  }
    
  enum BinaryFlags {
    static let authorizated: UInt32 = 1 << 0
    static let authorizatedToMaintainLiabilities: UInt32 = 1 << 1
    static let trustlineClawbackEnabled: UInt32 = 1 << 2
  }
  
  static func mapFlags(flags: UInt32) -> String {
    let binaryFlagsArray: [UInt32] = [BinaryFlags.authorizated, BinaryFlags.authorizatedToMaintainLiabilities, BinaryFlags.trustlineClawbackEnabled]
    var resultFlagsArray: [UInt32] = []
    var resultFlagsStringArray: [String] = []
    var flagsString: String = ""
    
    for flag in binaryFlagsArray {
      let resultFlag = flags & flag
      if resultFlag != 0 {
        resultFlagsArray.append(resultFlag)
      }
    }
    
    for flag in resultFlagsArray {
      if flag == BinaryFlags.authorizated {
        resultFlagsStringArray.append("Authorized")
      } else if flag == BinaryFlags.authorizatedToMaintainLiabilities {
        resultFlagsStringArray.append("Authorized To Maintain Liabilities")
      } else if flag == BinaryFlags.trustlineClawbackEnabled {
        resultFlagsStringArray.append("Trustline Clawback Enabled")
      } else {
        resultFlagsStringArray.append("Unknown")
      }
    }
    
    if resultFlagsStringArray.count > 1 {
      flagsString = resultFlagsStringArray.joined(separator: "\n")
    } else {
      flagsString = resultFlagsStringArray.first ?? ""
    }
    return flagsString
  }
}

// MARK: - Formatting

extension Price {
  var formattedString: String {
    let priceDouble = Double(self.n) / Double(self.d)
    return priceDouble.formattedString
  }
}

extension Double {
  var formattedString: String {
    let number = NSNumber(value: self)
    return PriceFormatter.shared.string(from: number) ?? "unknown"
  }
}

extension Decimal {
  var formattedString: String {
    let decimalNumber = NSDecimalNumber(decimal: self)
    return PriceFormatter.shared.string(from: decimalNumber) ?? "unknown"
  }
}

class PriceFormatter: NumberFormatter {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  static let shared = PriceFormatter()
  override init() {
    super.init()
    self.numberStyle = .decimal
    self.maximumFractionDigits = 7
    self.groupingSeparator = ","
    self.decimalSeparator = "."
  }
}

