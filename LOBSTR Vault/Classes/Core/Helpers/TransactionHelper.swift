import Foundation
import stellarsdk

struct TransactionHelper {
  static let storage: AccountsStorage = AccountsStorageDiskImpl()
  static var storageAccounts: [SignedAccount] = []
  
  static let numberOfCharacters = getNumberOfCharactersForTruncatePublicKeyTransactionDetails()
  
  static var operationsCount = 0
  
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
      let conditions = tV0Xdr.timeBounds != nil ? PreconditionsXDR.time(tV0Xdr.timeBounds!) : .none
      let transactionXdr = TransactionXDR(sourceAccount: pk,
                                          seqNum: tV0Xdr.seqNum,
                                          cond: conditions,
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
    
      let operationType = OperationType(rawValue: operationTypeValue)
    
      if let type = operationType {
        var name = ""
        switch type {
        case .accountCreated:
          name = L10n.textOperationNameCreateAccount
        case .manageSellOffer:
          guard let manageOperation = try? stellarsdk.Operation.fromXDR(operationXDR: operation) as? ManageOfferOperation else {
            name = L10n.textOperationNameSellOffer
            continue
          }
          name = manageOperation.amount == 0 && manageOperation.offerId != 0 ? L10n.textOperationNameCancelOffer : L10n.textOperationNameSellOffer
        case .manageBuyOffer:
          guard let manageOperation = try? stellarsdk.Operation.fromXDR(operationXDR: operation) as? ManageOfferOperation else {
            name = L10n.textOperationNameManageBuyOffer
            continue
          }
          name = manageOperation.amount == 0 && manageOperation.offerId != 0 ? L10n.textOperationNameCancelOffer : L10n.textOperationNameManageBuyOffer
        case .manageData:
          if let transactionType = transactionType {
            switch transactionType {
            case .authChallenge:
              name = L10n.textOperationNameChallengeTitle
            default:
              name = type.description
            }
          } else {
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
                name = L10n.textOperationNameRevokeAccountSponsorship
              case .claimableBalance:
                name = L10n.textOperationNameRevokeClaimableBalanceSponsorship
              case .data:
                name = L10n.textOperationNameRevokeDataSponsorship
              case .offer:
                name = L10n.textOperationNameRevokeOfferSponsorship
              case .trustline:
                name = L10n.textOperationNameRevokeTrustlineSponsorship
              case .liquidityPool, .contractData, .contractCode, .configSetting, .ttl:
                name = ""
              }
            } else {
              name = L10n.textOperationNameRevokeSignerSponsorship
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
          
        case .liquidityPool, .contractData, .contractCode, .configSetting, .ttl:
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
      
    case is ExtendFootprintTTLOperation.Type:
      let extendFootprintTTLOperation = operation as! ExtendFootprintTTLOperation
      if let operationSourceAccountId = extendFootprintTTLOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is RestoreFootprintOperation.Type:
      let restoreFootprintOperation = operation as! RestoreFootprintOperation
      if let operationSourceAccountId = restoreFootprintOperation.sourceAccountId {
        publicKeys.append(operationSourceAccountId)
      }
    case is InvokeHostFunctionOperation.Type:
      let invokeHostFunctionOperation = operation as! InvokeHostFunctionOperation
      switch invokeHostFunctionOperation.hostFunction {
      case .createContract(let createContract):
        switch createContract.contractIDPreimage {
        case .fromAddress(let preimage):
          if let address = preimage.address.accountId {
            publicKeys.append(address)
          }
        case .fromAsset(let preimage):
          if let issuer = preimage.issuer?.accountId {
            publicKeys.append(issuer)
          }
        }
      case .invokeContract(let invokeContract):
        if let address = invokeContract.contractAddress.accountId {
          publicKeys.append(address)
        }
        
        for scVal in invokeContract.args {
          getPublicKeyFromSCValXDR(args: scVal, publicKeys: &publicKeys)
        }
      default:
        break
      }
      
      for auth in invokeHostFunctionOperation.auth {
        switch auth.credentials {
        case .sourceAccount:
          break
        case .address(let address):
          
          switch address.address {
          case .account(let account):
            publicKeys.append(account.accountId)
          default:
            break
          }
          getPublicKeyFromSCValXDR(args: address.signature, publicKeys: &publicKeys)
        }
        
        switch auth.rootInvocation.function {
        case .contractFn(let contract):
          switch contract.contractAddress {
          case .account(let account):
            publicKeys.append(account.accountId)
          default:
            break
          }
          for arg in contract.args {
            getPublicKeyFromSCValXDR(args: arg, publicKeys: &publicKeys)
          }
        case .contractHostFn(let args):
          switch args.contractIDPreimage {
          case .fromAddress(let preimage):
            if let address = preimage.address.accountId {
              publicKeys.append(address)
            }
          case .fromAsset(let preimage):
            if let issuer = preimage.issuer?.accountId {
              publicKeys.append(issuer)
            }
          }
        }
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
      assets.append(paymentOperation.asset)
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
            if let asset = stellarsdk.Asset(type: ledgerKey.asset.type(), code: ledgerKey.asset.assetCode, issuer: KeyPair(publicKey: publicKey)) {
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
  
  static func parseOperation(from operation: stellarsdk.Operation, transactionSourceAccountId: String, isListOperations: Bool = false, destinationFederation: String = "") -> [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)] {
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
      if let operationSourceAccountId = paymentOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is CreateAccountOperation.Type:
      let createAccountOperation = operation as! CreateAccountOperation
      data.append(("Destination", createAccountOperation.destination.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: createAccountOperation.destination.accountId), true, false))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Asset", "XLM", "", false, true))
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
      if !pathPaymentOperation.path.isEmpty {
        data.append(("Path", getPathPaymentPathValue(pathPaymentOperation: pathPaymentOperation), "", false, false))
      }
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
        data.append(("Value", value.utf8String ?? "none", "", false, false))
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
          let result = PredicateHelper.evaluateClaimPredicate(claimant.predicate, now: Date())
          number += 1
          data.append(("Claimant \(number)", claimant.destination.getTruncatedPublicKey(), tryToGetNickname(publicKey: claimant.destination), true, false))
          data.append((getPredicateTitle(result), getBeautifulPredicateDate(result), "", false, false))
        }
      } else {
        if let claimant = createClaimableBalanceOperation.claimants.first {
          data.append(("Claimant", claimant.destination.getTruncatedPublicKey(), tryToGetNickname(publicKey: claimant.destination), true, false))
          let result = PredicateHelper.evaluateClaimPredicate(claimant.predicate, now: Date())
          data.append((getPredicateTitle(result), getBeautifulPredicateDate(result), "", false, false))
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
          
        case .contractData, .contractCode, .configSetting, .ttl:
          break
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
    case is ExtendFootprintTTLOperation.Type:
      let extendFootprintTTLOperation = operation as! ExtendFootprintTTLOperation
      if let operationSourceAccountId = extendFootprintTTLOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
      data.append(("Extend To", extendFootprintTTLOperation.extendTo.description, "", false, false))
    case is RestoreFootprintOperation.Type:
      let restoreFootprintOperation = operation as! RestoreFootprintOperation
      if let operationSourceAccountId = restoreFootprintOperation.sourceAccountId,
          transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey(numberOfCharacters: numberOfCharacters), tryToGetNickname(publicKey: operationSourceAccountId), true, false))
      }
    case is InvokeHostFunctionOperation.Type:
      let invokeHostFunctionOperation = operation as! InvokeHostFunctionOperation
      switch invokeHostFunctionOperation.hostFunction {
      case .createContract(let createContract):
        data.append(("Function", "Create Contract", "", false, false))
        switch createContract.contractIDPreimage {
        case .fromAddress(let preimage):
          data.append(("Contract ID Preimage", "From Address", "", false, false))
          if let address = preimage.address.accountId {
            data.append(("Account ID", address.getTruncatedPublicKey(), tryToGetNickname(publicKey: address), true, false))
          }
          let salt = getWrappedData32(data: preimage.salt)
          if !salt.isEmpty {
            data.append(("Salt", salt, "", false, false))
          }
        case .fromAsset(let preimage):
          data.append(("Contract ID Preimage", "From Asset", "", false, false))
          let assetCode = preimage.assetCode.isEmpty ? "XLM" : preimage.assetCode
          data.append(("Receive asset", assetCode, "", false, true))
          
          if let issuer = preimage.issuer?.accountId {
            data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
          }
        }
        switch createContract.executable {
        case .token:
          data.append(("Contract Executable", "Stellar Asset", "", false, false))
        case .wasm(let wasm):
          data.append(("Contract Executable", "Wasm", "", false, false))
          let wasmHash = getWrappedData32(data: wasm)
          if !wasmHash.isEmpty {
            data.append(("Wasm Hash", wasmHash, "", false, false))
          }
        }
      case .invokeContract(let invokeContract):
        data.append(("Function", "Invoke Contract", "", false, false))
        if let address = invokeContract.contractAddress.accountId {
          data.append(("Account ID", address.getTruncatedPublicKey(), tryToGetNickname(publicKey: address), true, false))
        }
        if let id = invokeContract.contractAddress.contractId {
          data.append(("Contract ID", id.getTruncatedPublicKey(), "", false, false))
        }
        data.append(("Function Name", invokeContract.functionName, "", false, false))
        
        for scVal in invokeContract.args {
          tryToSetSCValXDR(args: scVal, data: &data)
        }
        
      case .uploadContractWasm(let wasm):
        data.append(("Function", "Upload Contract Wasm", "", false, false))
        data.append(("Wasm", wasm.base64EncodedString(), "", false, false))
      }
      
      for auth in invokeHostFunctionOperation.auth {
        switch auth.credentials {
        case .sourceAccount:
          data.append(("Credentials", "Source Account", "", false, false))
        case .address(let address):
          data.append(("Credentials", "Address", "", false, false))
          switch address.address {
          case .account(let account):
            data.append(("Account ID", account.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: account.accountId), true, false))
          case .contract(let contract):
            let capacity = getWrappedData32(data: contract)
            if !capacity.isEmpty {
              data.append(("Capacity", capacity, "", false, false))
            }
          }
          data.append(("Nonce", "\(address.nonce)", "", false, false))
          data.append(("Signature Expiration Ledger", "\(address.signatureExpirationLedger)", "", false, false))
          tryToSetSCValXDR(args: address.signature, data: &data)
        }
        
        switch auth.rootInvocation.function {
        case .contractFn(let contract):
          data.append(("Authorized Function", "Contract", "", false, false))
          switch contract.contractAddress {
          case .account(let account):
            data.append(("Account ID", account.accountId.getTruncatedPublicKey(), tryToGetNickname(publicKey: account.accountId), true, false))
          case .contract(let contract):
            let capacity = getWrappedData32(data: contract)
            if !capacity.isEmpty {
              data.append(("Capacity", capacity, "", false, false))
            }
          }
          data.append(("Function Name", contract.functionName, "", false, false))
          for arg in contract.args {
            tryToSetSCValXDR(args: arg, data: &data)
          }
        case .contractHostFn(let args):
          data.append(("Authorized Function", "Contract Host", "", false, false))
          switch args.contractIDPreimage {
          case .fromAddress(let preimage):
            data.append(("Contract ID Preimage", "From Address", "", false, false))
            if let address = preimage.address.accountId {
              data.append(("Account ID", address.getTruncatedPublicKey(), tryToGetNickname(publicKey: address), true, false))
            }
            let salt = getWrappedData32(data: preimage.salt)
            if !salt.isEmpty {
              data.append(("Salt", salt, "", false, false))
            }
          case .fromAsset(let preimage):
            data.append(("Contract ID Preimage", "From Asset", "", false, false))
            let assetCode = preimage.assetCode.isEmpty ? "XLM" : preimage.assetCode
            data.append(("Receive asset", assetCode, "", false, true))
            
            if let issuer = preimage.issuer?.accountId {
              data.append(("Asset Issuer", issuer.getTruncatedPublicKey(), tryToGetNickname(publicKey: issuer), true, false))
            }
          }
          switch args.executable {
          case .token:
            data.append(("Contract Executable", "Stellar Asset", "", false, false))
          case .wasm(let wasm):
            data.append(("Contract Executable", "Wasm", "", false, false))
            let wasmHash = getWrappedData32(data: wasm)
            if !wasmHash.isEmpty {
              data.append(("Wasm Hash", wasmHash, "", false, false))
            }
          }
        }
      }
    default:
      break
    }
    
    return data
  }
    
  // parse SCValXDR
  static func tryToSetSCValXDR(args: SCValXDR, data: inout [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)]) {
    switch args {
    case .bool(let bool):
      let value = bool ? "True" : "False"
      data.append(("Bool", value, "", false, false))
    case .timepoint(let timepoint):
      data.append(("Timepoint", "\(timepoint)", "", false, false))
    case .duration(let duration):
      data.append(("Duration", "\(duration)", "", false, false))
    case .symbol(let symbol):
      data.append(("Symbol", symbol, "", false, false))
    case .string(let string):
      data.append(("String", string, "", false, false))
    case .bytes(let bytes):
      data.append(("Bytes", bytes.base64EncodedString(), "", false, false))
    case .address(let scAddress):
      switch scAddress {
      case .account(let account):
        data.append(("Account ID", account.accountId.getTruncatedPublicKey(),
                     tryToGetNickname(publicKey: account.accountId), true, false))
      case .contract(let contract):
        let capacity = getWrappedData32(data: contract)
        if !capacity.isEmpty {
          data.append(("Capacity", capacity, "", false, false))
        }
      }
    case .u32(let value):
      data.append(("U32", "\(value)", "", false, false))
    case .i32(let value):
      data.append(("I32", "\(value)", "", false, false))
    case .u64(let value):
      data.append(("U64", "\(value)", "", false, false))
    case .i64(let value):
      data.append(("I64", "\(value)", "", false, false))
    case .i128(let parts):
      let value = "hi: \(parts.hi), lo: \(parts.lo)"
      data.append(("I128", "\(value)", "", false, false))
    case .u128(let parts):
      let value = "hi: \(parts.hi), lo: \(parts.lo)"
      data.append(("U128", "\(value)", "", false, false))
    case .u256(let parts):
      let value = "hi_hi: \(parts.hiHi), hi_lo: \(parts.hiLo), lo_hi: \(parts.loHi), lo_lo: \(parts.loLo)"
      data.append(("U256", "\(value)", "", false, false))
    case .i256(let parts):
      let value = "hi_hi: \(parts.hiHi), hi_lo: \(parts.hiLo), lo_hi: \(parts.loHi), lo_lo: \(parts.loLo)"
      data.append(("I256", "\(value)", "", false, false))
    case .contractInstance(let contract):
      switch contract.executable {
      case .token:
        data.append(("Contract Executable", "Stellar Asset", "", false, false))
      case .wasm(let wasm):
        data.append(("Contract Executable", "Wasm", "", false, false))
        let wasmHash = getWrappedData32(data: wasm)
        if !wasmHash.isEmpty {
          data.append(("Wasm Hash", wasmHash, "", false, false))
        }
      }
    case .ledgerKeyContractInstance:
      break
    case .ledgerKeyNonce(let key):
      data.append(("Nonce Key", "\(key.nonce)", "", false, false))
    case .void:
      break
    case .error:
      break
    default:
      break
    }
  }

  static func getWrappedData32(data: WrappedData32) -> String {
    let encodedString = data.wrapped.base64EncodedString()
    if encodedString.isEmpty {
      return ""
    } else {
      if encodedString.count > 16 {
        return "\(encodedString.prefix(8))...\(encodedString.suffix(8))"
      } else {
        return encodedString
        
      }
    }
  }
  
  static func getPublicKeyFromSCValXDR(args: SCValXDR, publicKeys: inout [String]) {
    switch args {
    case .address(let scAddress):
      switch scAddress {
      case .account(let account):
        publicKeys.append(account.accountId)
      default:
        break
      }
    default:
      break
    }
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
  
  static func getPathPaymentPathValue(pathPaymentOperation: PathPaymentOperation) -> String {
    return pathPaymentOperation.path.map { asset in
      return asset.code ?? "XLM"
    }.joined(separator: " ")
  }
  
  static func tryToGetNickname(publicKey: String) -> String {
    self.storageAccounts = AccountsStorageHelper.getStoredAccounts()
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
    let formatter: String? = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)
    
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
        } else {
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
    let formatter: String? = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)
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
  (resultCode: TransactionResultCode, operationMessageError: String?)
  {
    guard let errorMessage = try? JSONDecoder().decode(HorizonErrorMessage.self,
                                                       from: message.data(using: String.Encoding.utf8)!)
    else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard let resultXDR = errorMessage.extras?.result_xdr else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard let transactionResultXDR = try? TransactionResultXDR(xdr: resultXDR) else {
      throw VaultError.TransactionError.invalidTransaction
    }
      
    var operationMessageError: String?
    var resultCode = transactionResultXDR.code
    
    if let resultBody = transactionResultXDR.resultBody {
      let operationResultCodes = getOperationsResultCodes(from: resultBody)
      if checkIsBadAuth(operationResultCodes) {
        resultCode = .badAuth
      } else {
        operationMessageError = tryToGetOperationErrorMessage(from: resultBody)
      }
    }
    return (resultCode, operationMessageError)
  }
  
  // MARK: - Operations Errors Parsing
  
  static func tryToGetOperationErrorMessage(from resultBody: TransactionResultBodyXDR) -> String? {
    switch resultBody {
    case let .failed(operations):
      operationsCount = operations.count
      for (index, operation) in operations.enumerated() {
        switch operation {
        case .createAccount(_, let createAccountResultXDR):
          if let message = getCreateAccountOperationErrorMessage(createAccountResultXDR, operation: operation, index: index) {
            return message
          }
        case .payment(_, let paymentResultXDR):
          if let message = getPaymentOperationErrorMessage(paymentResultXDR, operation: operation, index: index) {
            return message
          }
        case .pathPayment(_, let pathPaymentResultXDR), .pathPaymentStrictSend(_, let pathPaymentResultXDR):
          if let message = getPathPaymentOperationErrorMessage(pathPaymentResultXDR, operation: operation, index: index) {
            return message
          }
        case .manageSellOffer(_, let manageOfferResultXDR), .createPassiveSellOffer(_, let manageOfferResultXDR), .manageBuyOffer(_, let manageOfferResultXDR):
          if let message = getManageOfferOperationErrorMessage(manageOfferResultXDR, operation: operation, index: index) {
            return message
          }
        case .setOptions(_, let setOptionsResultXDR):
          if let message = getSetOptionsOperationErrorMessage(setOptionsResultXDR, operation: operation, index: index) {
            return message
          }
        case .changeTrust(_, let changeTrustResultXDR):
          if let message = getChangeTrustOperationErrorMessage(changeTrustResultXDR, operation: operation, index: index) {
            return message
          }
        case .allowTrust(_, let allowTrustResultXDR):
          if let message = getAllowTrustOperationErrorMessage(allowTrustResultXDR, operation: operation, index: index) {
            return message
          }
        case .accountMerge(_, let accountMergeResultXDR):
          if let message = getAccountMergeOperationErrorMessage(accountMergeResultXDR, operation: operation, index: index) {
            return message
          }
        case .inflation(_, let inflationResultXDR):
          if let message = getInflationOperationErrorMessage(inflationResultXDR, operation: operation, index: index) {
            return message
          }
        case .manageData(_, let manageDataResultXDR):
          if let message = getManageDataOperationErrorMessage(manageDataResultXDR, operation: operation, index: index) {
            return message
          }
        case .bumpSequence(_, let bumpSequenceResultXDR):
          if let message = getBumpSequenceOperationErrorMessage(bumpSequenceResultXDR, operation: operation, index: index) {
            return message
          }
        case .createClaimableBalance(_, let createClaimableBalanceResultXDR):
          if let message = getCreateClaimableBalanceOperationErrorMessage(createClaimableBalanceResultXDR, operation: operation, index: index) {
            return message
          }
        case .claimClaimableBalance(_, let claimClaimableBalanceResultXDR):
          if let message = getClaimClaimableBalanceOperationErrorMessage(claimClaimableBalanceResultXDR, operation: operation, index: index) {
            return message
          }
        case .beginSponsoringFutureReserves(_, let beginSponsoringFutureReservesResultXDR):
          if let message = getBeginSponsoringFutureReservesOperationErrorMessage(beginSponsoringFutureReservesResultXDR, operation: operation, index: index) {
            return message
          }
        case .endSponsoringFutureReserves(_, let endSponsoringFutureReservesResultXDR):
          if let message = getEndSponsoringFutureReservesOperationErrorMessage(endSponsoringFutureReservesResultXDR, operation: operation, index: index) {
            return message
          }
        case .revokeSponsorship(_, let revokeSponsorshipResultXDR):
          if let message = getRevokeSponsorshipOperationErrorMessage(revokeSponsorshipResultXDR, operation: operation, index: index) {
            return message
          }
        case .clawback(_, let clawbackResultXDR):
          if let message = getClawbackOperationErrorMessage(clawbackResultXDR, operation: operation, index: index) {
            return message
          }
        case .clawbackClaimableBalance(_, let clawbackClaimableBalanceResultXDR):
          if let message = getClawbackClaimableBalanceOperationErrorMessage(clawbackClaimableBalanceResultXDR, operation: operation, index: index) {
            return message
          }
        case .setTrustLineFlags(_, let setTrustLineFlagsResultXDR):
          if let message = getSetTrustLineFlagsOperationErrorMessage(setTrustLineFlagsResultXDR, operation: operation, index: index) {
            return message
          }
        case .liquidityPoolDeposit(_, let liquidityPoolDepositResultXDR):
          if let message = getLiquidityPoolDepositOperationErrorMessage(liquidityPoolDepositResultXDR, operation: operation, index: index) {
            return message
          }
        case .liquidityPoolWithdraw(_, let liquidityPoolWithdrawResultXDR):
          if let message = getLiquidityPoolWithdrawOperationErrorMessage(liquidityPoolWithdrawResultXDR, operation: operation, index: index) {
            return message
          }
        case .invokeHostFunction(_, let invokeHostFunctionResultXDR):
          if let message = getInvokeHostFunctionOperationErrorMessage(invokeHostFunctionResultXDR, operation: operation, index: index) {
            return message
          }
        case .extendFootprintTTL(_, let extendFootprintTTLResultXDR):
          if let message = getExtendFootprintTTLOperationErrorMessage(extendFootprintTTLResultXDR, operation: operation, index: index) {
            return message
          }
        case .restoreFootprint(_, let restoreFootprintResultXDR):
          if let message = getRestoreFootprintOperationErrorMessage(restoreFootprintResultXDR, operation: operation, index: index) {
            return message
          }
        case .empty(let errorCode):
          switch OperationResultCode(rawValue: errorCode) {
          case .badAuth:
            return L10n.opBadAuth
          case .noAccount:
            return L10n.opNoAccount
          case .notSupported:
            return L10n.opNotSupported
          case .tooManySubentries:
            return L10n.errorTooManySubentriesMessage
          case .exceededWorkLimit:
            return L10n.opExceedWorkLimit
          case .tooManySponsoring:
            return L10n.opTooManySponsoring
          default: break
          }
        }
      }
    default: break
    }
    return nil
  }
  
  private static func checkIsBadAuth(_ codes: [OperationResultCode]) -> Bool {
    let operationErrors = codes.filter { $0 != .inner }
    if !operationErrors.isEmpty {
      let isBadAuth = operationErrors.allSatisfy { $0 == .badAuth }
      return isBadAuth
    } else {
      return false
    }
  }
  
  private static func getOperationsResultCodes(from resultBody: TransactionResultBodyXDR) -> [OperationResultCode] {
    var operationResultCodes: [OperationResultCode] = []
    switch resultBody {
    case let .failed(operations):
      for operation in operations {
        switch operation {
        case .createAccount(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .payment(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .pathPayment(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .manageSellOffer(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .createPassiveSellOffer(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .setOptions(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .changeTrust(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .allowTrust(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .accountMerge(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .inflation(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .manageData(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .bumpSequence(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .manageBuyOffer(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .pathPaymentStrictSend(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .createClaimableBalance(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .claimClaimableBalance(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .beginSponsoringFutureReserves(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .endSponsoringFutureReserves(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .revokeSponsorship(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .clawback(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .clawbackClaimableBalance(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .setTrustLineFlags(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .liquidityPoolDeposit(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .liquidityPoolWithdraw(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .invokeHostFunction(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .empty(let errorCode):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .extendFootprintTTL(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        case .restoreFootprint(let errorCode, _):
          if let operationResultCode = OperationResultCode(rawValue: errorCode) {
            operationResultCodes.append(operationResultCode)
          }
        }
      }
    default: break
    }
    return operationResultCodes
  }
  
  private static func getCreateAccountOperationErrorMessage(_ createAccountResultXDR: CreateAccountResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch createAccountResultXDR {
    case .empty(let errorCode):
      switch CreateAccountResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.createAccountMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfunded:
        operationErrorMessage = L10n.createAccountUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.createAccountLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .alreadyExists:
        operationErrorMessage = L10n.createAccountAlreadyExist
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getPaymentOperationErrorMessage(_ paymentResultXDR: PaymentResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch paymentResultXDR {
    case .empty(let errorCode):
      switch PaymentResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.paymentMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfunded:
        operationErrorMessage = L10n.paymentUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .srcNoTrust:
        operationErrorMessage = L10n.paymentSrcNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .srcNotAuthorized:
        operationErrorMessage = L10n.paymentSrcNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noDestination:
        operationErrorMessage = L10n.paymentNoDestination
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrust:
        operationErrorMessage = L10n.paymentNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notAuthorized:
        operationErrorMessage = L10n.paymentNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lineFull:
        operationErrorMessage = L10n.paymentLineFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noIssuer:
        operationErrorMessage = L10n.paymentNoIssuer
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getPathPaymentOperationErrorMessage(_ pathPaymentResultXDR: PathPaymentResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch pathPaymentResultXDR {
    case .empty(let errorCode):
      switch PathPaymentResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.pathPaymentStrictMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfounded:
        operationErrorMessage = L10n.pathPaymentStrictUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .srcNoTrust:
        operationErrorMessage = L10n.pathPaymentStrictSrcNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .srcNotAuthorized:
        operationErrorMessage = L10n.pathPaymentStrictSrcNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noDestination:
        operationErrorMessage = L10n.pathPaymentStrictNoDestination
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrust:
        operationErrorMessage = L10n.pathPaymentStrictNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notAuthorized:
        operationErrorMessage = L10n.pathPaymentStrictNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lineFull:
        operationErrorMessage = L10n.pathPaymentStrictLineFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noIssuer:
        operationErrorMessage = L10n.pathPaymentStrictNoIssuer
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .tooFewOffers:
        operationErrorMessage = L10n.pathPaymentStrictTooFewOffers
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .offerCrossSelf:
        operationErrorMessage = L10n.pathPaymentStrictOfferCrossSelf
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .overSendMax:
        operationErrorMessage = L10n.pathPaymentStrictReceiveOverSendmax
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getManageOfferOperationErrorMessage(_ manageOfferResultXDR: ManageOfferResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch manageOfferResultXDR {
    case .empty(let errorCode):
      switch ManageOfferResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.manageOfferMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .sellNoTrust:
        operationErrorMessage = L10n.manageOfferSellNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .buyNoTrust:
        operationErrorMessage = L10n.manageOfferBuyNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .sellNotAuthorized:
        operationErrorMessage = L10n.manageOfferSellNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .buyNotAuthorized:
        operationErrorMessage = L10n.manageOfferBuyNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lineFull:
        operationErrorMessage = L10n.manageOfferLineFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfunded:
        operationErrorMessage = L10n.manageOfferUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .crossSelf:
        operationErrorMessage = L10n.manageOfferCrossSelf
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .sellNoIssuer:
        operationErrorMessage = L10n.manageOfferSellNoIssuer
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .buyNoIssuer:
        operationErrorMessage = L10n.manageOfferBuyNoIssuer
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notFound:
        operationErrorMessage = L10n.manageOfferNotFound
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.manageOfferLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getSetOptionsOperationErrorMessage(_ setOptionsResultXDR: SetOptionsResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch setOptionsResultXDR {
    case .empty(let errorCode):
      switch SetOptionsResultCode(rawValue: errorCode) {
      case .lowReserve:
        operationErrorMessage = L10n.setOptionsLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .tooManySigners:
        operationErrorMessage = L10n.setOptionsTooManySigners
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .badFlags:
        operationErrorMessage = L10n.setOptionsBadFlags
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .invalidInflation:
        operationErrorMessage = L10n.setOptionsInvalidInflation
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .cantChange:
        operationErrorMessage = L10n.setOptionsCantChange
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .unknownFlag:
        operationErrorMessage = L10n.setOptionsUnknownFlag
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .thresholdOutOfRange:
        operationErrorMessage = L10n.setOptionsThresholdOutOfRange
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .badSigner:
        operationErrorMessage = L10n.setOptionsBadSigner
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .invalidHomeDomain:
        operationErrorMessage = L10n.setOptionsInvalidHomeDomain
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getChangeTrustOperationErrorMessage(_ changeTrustResultXDR: ChangeTrustResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch changeTrustResultXDR {
    case .empty(let errorCode):
      switch ChangeTrustResultCode(rawValue: errorCode) {
      case .trustMalformed:
        operationErrorMessage = L10n.changeTrustMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noIssuer:
        operationErrorMessage = L10n.changeTrustNoIssuer
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .trustInvalidLimit:
        operationErrorMessage = L10n.changeTrustInvalidLimit
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .changeTrustLowReserve:
        operationErrorMessage = L10n.changeTrustLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .changeTrustSelfNotAllowed:
        operationErrorMessage = L10n.changeTrustSelfNotAllowed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .trustlineMissing:
        operationErrorMessage = L10n.changeTrustTrustLineMissing
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .cannotDelete:
        operationErrorMessage = L10n.changeTrustCannotDelete
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notAuthMaintainLiabilities:
        operationErrorMessage = L10n.changeTrustNotAuthMaintainLiabilities
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getAllowTrustOperationErrorMessage(_ allowTrustResultXDR: AllowTrustResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch allowTrustResultXDR {
    case .empty(let errorCode):
      switch AllowTrustResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.allowTrustMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrustline:
        operationErrorMessage = L10n.allowTrustNoTrustLine
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .trustNotRequired:
        operationErrorMessage = L10n.allowTrustTrustNotRequired
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .cantRevoke:
        operationErrorMessage = L10n.allowTrustCantRevoke
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .selfNotAllowed:
        operationErrorMessage = L10n.allowTrustSelfNotAllowed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.allowTrustLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getAccountMergeOperationErrorMessage(_ accountMergeResultXDR: AccountMergeResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch accountMergeResultXDR {
    case .empty(let errorCode):
      switch AccountMergeResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.accountMergeMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noAccount:
        operationErrorMessage = L10n.accountMergeNoAccount
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .immutableSet:
        operationErrorMessage = L10n.accountMergeImmutableSet
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .hasSubEntries:
        operationErrorMessage = L10n.accountMergeHasSubEntries
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .seqnumTooFar:
        operationErrorMessage = L10n.accountMergeSeqnumToFar
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .destinationFull:
        operationErrorMessage = L10n.accountMergeDestFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .isSponsor:
        operationErrorMessage = L10n.accountMergeIsSponsor
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getInflationOperationErrorMessage(_ inflationResultXDR: InflationResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch inflationResultXDR {
    case .empty(let errorCode):
      switch InflationResultCode(rawValue: errorCode) {
      case .notTime:
        operationErrorMessage = L10n.inflationNotTime
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getManageDataOperationErrorMessage(_ manageDataResultXDR: ManageDataResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch manageDataResultXDR {
    case .empty(let errorCode):
      switch ManageDataResultCode(rawValue: errorCode) {
      case .notSupportedYet:
        operationErrorMessage = L10n.manageDataNotSupportedYet
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .nameNotFound:
        operationErrorMessage = L10n.manageDataNameNotFound
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.manageDataLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .invalidName:
        operationErrorMessage = L10n.manageDataInvalidName
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getBumpSequenceOperationErrorMessage(_ bumpSequenceResultXDR: BumpSequenceResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch bumpSequenceResultXDR {
    case .empty(let errorCode):
      switch BumpSequenceResultCode(rawValue: errorCode) {
      case .bad_seq:
        operationErrorMessage = L10n.bumpSequnceBadSeq
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getCreateClaimableBalanceOperationErrorMessage(_ createClaimableBalanceResultXDR: CreateClaimableBalanceResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch createClaimableBalanceResultXDR {
    case .empty(let errorCode):
      switch CreateClaimableBalanceResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.createClaimableBalanceMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.createClaimableBalanceLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrust:
        operationErrorMessage = L10n.createClaimableBalanceNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notAUthorized:
        operationErrorMessage = L10n.createClaimableBalanceNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfunded:
        operationErrorMessage = L10n.createClaimableBalanceUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getClaimClaimableBalanceOperationErrorMessage(_ claimClaimableBalanceResultXDR: ClaimClaimableBalanceResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch claimClaimableBalanceResultXDR {
    case .empty(let errorCode):
      switch ClaimClaimableBalanceResultCode(rawValue: errorCode) {
      case .doesNotExist:
        operationErrorMessage = L10n.claimClaimableBalanceDoesNotExist
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .cannotClaim:
        operationErrorMessage = L10n.claimClaimableBalanceCannotClaim
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lineFill:
        operationErrorMessage = L10n.claimClaimableBalanceLineFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrust:
        operationErrorMessage = L10n.claimClaimableBalanceNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notAUthorized:
        operationErrorMessage = L10n.claimClaimableBalanceNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getBeginSponsoringFutureReservesOperationErrorMessage(_ beginSponsoringFutureReservesResultXDR: BeginSponsoringFutureReservesResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch beginSponsoringFutureReservesResultXDR {
    case .empty(let errorCode):
      switch BeginSponsoringFutureReservesResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.beginSponsoringFutureReservesMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .alreadySponsored:
        operationErrorMessage = L10n.beginSponsoringFutureReservesAlreadySponsored
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .recursive:
        operationErrorMessage = L10n.beginSponsoringFutureReservesRecursive
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getEndSponsoringFutureReservesOperationErrorMessage(_ endSponsoringFutureReservesResultXDR: EndSponsoringFutureReservesResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch endSponsoringFutureReservesResultXDR {
    case .empty(let errorCode):
      switch EndSponsoringFutureReservesResultCode(rawValue: errorCode) {
      case .notSponsored:
        operationErrorMessage = L10n.endSponsoringFutureReservesNotSponsored
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getRevokeSponsorshipOperationErrorMessage(_ revokeSponsorshipResultXDR: RevokeSponsorshipResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch revokeSponsorshipResultXDR {
    case .empty(let errorCode):
      switch RevokeSponsorshipResultCode(rawValue: errorCode) {
      case .doesNotExist:
        operationErrorMessage = L10n.revokeSponsorshipDoesNotExist
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notSponsored:
        operationErrorMessage = L10n.revokeSponsorshipNotSponsor
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.revokeSponsorshipLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .onlyTransferabel:
        operationErrorMessage = L10n.revokeSponsorshipOnlyTransferable
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .malformed:
        operationErrorMessage = L10n.revokeSponsorshipMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getClawbackOperationErrorMessage(_ clawbackResultXDR: ClawbackResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch clawbackResultXDR {
    case .empty(let errorCode):
      switch ClawbackResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.clawbackMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notClawbackEnabled:
        operationErrorMessage = L10n.clawbackNotClawbackEnabled
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrust:
        operationErrorMessage = L10n.clawbackNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .unterfunded:
        operationErrorMessage = L10n.clawbackUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getClawbackClaimableBalanceOperationErrorMessage(_ clawbackClaimableBalanceResultXDR: ClawbackClaimableBalanceResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch clawbackClaimableBalanceResultXDR {
    case .empty(let errorCode):
      switch ClawbackClaimableBalanceResultCode(rawValue: errorCode) {
      case .doesNotExist:
        operationErrorMessage = L10n.clawbackClaimableBalanceDoesNotExist
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notIssuer:
        operationErrorMessage = L10n.clawbackClaimableBalanceNotIssuer
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notClawbackEnabled:
        operationErrorMessage = L10n.clawbackClaimableBalanceNotClawbackEnabled
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getSetTrustLineFlagsOperationErrorMessage(_ setTrustLineFlagsResultXDR: SetTrustLineFlagsResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch setTrustLineFlagsResultXDR {
    case .empty(let errorCode):
      switch SetTrustLineFlagsResultCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.setTrustLineFlagsMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrustLine:
        operationErrorMessage = L10n.setTrustLineFlagsNoTrustLine
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .cantRevoke:
        operationErrorMessage = L10n.setTrustLineFlagsCantRevoke
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .invalidState:
        operationErrorMessage = L10n.setTrustLineFlagsInvalidState
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lowReserve:
        operationErrorMessage = L10n.setTrustLineFlagsLowReserve
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }

  private static func getLiquidityPoolDepositOperationErrorMessage(_ liquidityPoolDepositResultXDR: LiquidityPoolDepositResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch liquidityPoolDepositResultXDR {
    case .empty(let errorCode):
      switch LiquidityPoolDepositResulCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.liquidityPoolDepositMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrustLine:
        operationErrorMessage = L10n.liquidityPoolDepositNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .notAuhorized:
        operationErrorMessage = L10n.liquidityPoolDepositNotAuthorized
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfunded:
        operationErrorMessage = L10n.liquidityPoolDepositUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lineFull:
        operationErrorMessage = L10n.liquidityPoolDepositLineFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .badPrice:
        operationErrorMessage = L10n.liquidityPoolDepositBadPrice
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .poolFull:
        operationErrorMessage = L10n.liquidityPoolDepositPoolFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getLiquidityPoolWithdrawOperationErrorMessage(_ liquidityPoolWithdrawResultXDR: LiquidityPoolWithdrawResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch liquidityPoolWithdrawResultXDR {
    case .empty(let errorCode):
      switch LiquidityPoolWithdrawResulCode(rawValue: errorCode) {
      case .malformed:
        operationErrorMessage = L10n.liquidityPoolWithdrawMalformed
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .noTrustLine:
        operationErrorMessage = L10n.liquidityPoolWithdrawNoTrust
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underfunded:
        operationErrorMessage = L10n.liquidityPoolWithdrawUnderfunded
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .lineFull:
        operationErrorMessage = L10n.liquidityPoolWithdrawLineFull
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      case .underMinimum:
        operationErrorMessage = L10n.liquidityPoolWithdrawUnderMinimum
        return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
      default: break
      }
    default: break
    }
    return nil
  }
  
  private static func getInvokeHostFunctionOperationErrorMessage(_ invokeHostFunctionResultXDR: InvokeHostFunctionResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    switch invokeHostFunctionResultXDR {
    case .malformed:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    case .trapped:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    default:
      break
    }
    return nil
  }

  private static func getExtendFootprintTTLOperationErrorMessage(_ extendFootprintTTLResultXDR: ExtendFootprintTTLResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    
    switch extendFootprintTTLResultXDR {
    case .malformed:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    case .resourceLimitExceeded:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    case .insufficientRefundableFee:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    default:
      break
    }
    return nil
  }
  
  private static func getRestoreFootprintOperationErrorMessage(_ restoreFootprintResultXDR: RestoreFootprintResultXDR, operation: OperationResultXDR, index: Int) -> String? {
    var operationErrorMessage: String?
    
    switch restoreFootprintResultXDR {
    case .malformed:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    case .resourceLimitExceeded:
      operationErrorMessage = ""
      return getFullOperationErrorMessage(operation: operation, operationIndex: index, message: operationErrorMessage)
    default:
      break
    }
    return nil
  }
  
  private static func getFullOperationErrorMessage(operation: OperationResultXDR, operationIndex: Int, message: String?) -> String? {
    guard let message = message else { return nil }
    let fullOperationErrorMessage = operationsCount <= 1 ?
      L10n.textTvErrorShortDescription(operation.description) + " " + message :
      L10n.textTvErrorShortDescriptionWithNumber(operation.description, "\(operationIndex + 1)") + " " + message
    return fullOperationErrorMessage
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
  
  static func isVaultSigner(publicKey: String, completion: @escaping (Bool) -> Void) {
    let vaultStorage = VaultStorage()
    if let publicKeysFromKeychain = vaultStorage.getPublicKeysFromKeychain() {
      completion(publicKeysFromKeychain.contains(publicKey))
    } else if let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() {
      completion(publicKey == publicKeyFromKeychain)
    }
  }
  
  static func getShortPublicKey(_ key: String) -> String {
    var shortPublicKey = key.replacingOccurrences(of: " (", with: "")
    shortPublicKey = shortPublicKey.replacingOccurrences(of: ")", with: "")
    return shortPublicKey
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
  
  static func getBeautifulPredicateDate(_ claimResult: ClaimResult) -> String {
    let outputFormat = "dd MMM yyyy, HH:mm"

    let locale = Locale(identifier: "en_US")

    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.dateFormat = outputFormat
    
    // Expired
    if claimResult.expired {
      return L10n.textCantBeClaimed
    } else if claimResult.conflict { // Conflict
      return L10n.textCantBeClaimed
    }
    
    // Claim between.
    if let startPeriod = claimResult.startPeriod,
       let endPeriod = claimResult.endPeriod
    {
      return "\(formatter.string(from: startPeriod)) \n\(formatter.string(from: endPeriod))"
    } else if let startPeriod = claimResult.startPeriod { // Claim after
      return "\(formatter.string(from: startPeriod))"
    } else if let endPeriod = claimResult.endPeriod { // Claim before
      return "\(formatter.string(from: endPeriod))"
    }
    
    return L10n.textClaimNow
  }
  
  static func getPredicateTitle(_ claimResult: ClaimResult) -> String {
    // Expired
    if claimResult.expired {
      return L10n.textClaimConditions
    } else if claimResult.conflict { // Conflict
      return L10n.textClaimConditions
    }

    // Claim between.
    if let _ = claimResult.startPeriod,
       let _ = claimResult.endPeriod
    {
      return L10n.textClaimBetween
    } else if let _ = claimResult.startPeriod { // Claim after
      return L10n.textClaimAfter
    } else if let _ = claimResult.endPeriod { // Claim before
      return L10n.textClaimBefore
    }
    return L10n.textClaimConditions
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
