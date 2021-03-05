import Foundation
import stellarsdk

struct TransactionHelper {
  
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
  
  static func parseOperation(from operation: stellarsdk.Operation, transactionSourceAccountId: String, memo: String?, created: String?, isListOperations: Bool = false, destinationFederation: String = "") -> [(name: String, value: String)] {
    var data: [(name: String, value: String)] = []
    
    switch type(of: operation) {
    case is PaymentOperation.Type:
      let paymentOperation = operation as! PaymentOperation
      data.append(("Destination", paymentOperation.destinationAccountId.getTruncatedPublicKey()))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Asset", paymentOperation.asset.code ?? "XLM"))
      data.append(("Amount", paymentOperation.amount.description))
      if let issuer = paymentOperation.asset.issuer?.accountId, paymentOperation.asset.code != nil {
        data.append(("Asset Issuer", issuer.getTruncatedPublicKey()))
      }
      if let memo = memo, !memo.isEmpty {
        data.append(("Memo", memo.lowercased()))
      }
      
      if let operationSourceAccountId = paymentOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is CreateAccountOperation.Type:
      let createAccountOperation = operation as! CreateAccountOperation
      data.append(("Destination", createAccountOperation.destination.accountId.getTruncatedPublicKey()))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Starting Balance", createAccountOperation.startBalance.description))
      if let operationSourceAccountId = createAccountOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is PathPaymentOperation.Type:
      let pathPaymentOperation = operation as! PathPaymentOperation
      data.append(("Send Asset", pathPaymentOperation.sendAsset.code ?? "XLM"))
      if let sendIssuer = pathPaymentOperation.sendAsset.issuer?.accountId, pathPaymentOperation.sendAsset.code != nil {
        data.append(("Asset Issuer", sendIssuer.getTruncatedPublicKey()))
      }
      data.append(("Send Amount", pathPaymentOperation.sendMax.description))
      data.append(("Destination", pathPaymentOperation.destinationAccountId.getTruncatedPublicKey()))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      data.append(("Dest Asset", pathPaymentOperation.destAsset.code ?? "XLM"))
      if let destIssuer = pathPaymentOperation.destAsset.issuer?.accountId, pathPaymentOperation.destAsset.code != nil {
        data.append(("Asset Issuer", destIssuer.getTruncatedPublicKey()))
      }
      data.append(("Dest Min", pathPaymentOperation.destAmount.description))
      if let operationSourceAccountId = pathPaymentOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is ManageOfferOperation.Type:
      let manageOfferOperation = operation as! ManageOfferOperation
      data.append(("Selling", manageOfferOperation.selling.code ?? "XLM"))
      if let sellIssuer = manageOfferOperation.selling.issuer?.accountId, manageOfferOperation.selling.code != nil {
        data.append(("Asset Issuer", sellIssuer.getTruncatedPublicKey()))
      }
      data.append(("Buying", manageOfferOperation.buying.code ?? "XLM"))
      if let buyIssuer = manageOfferOperation.buying.issuer?.accountId, manageOfferOperation.buying.code != nil {
        data.append(("Asset Issuer", buyIssuer.getTruncatedPublicKey()))
      }
      if manageOfferOperation.amount != 0 {
        data.append(("Amount", manageOfferOperation.amount.description))
      }
      data.append(("Price", getPrice(from: manageOfferOperation.price)))
      if manageOfferOperation.offerId != 0 {
        data.append(("Offer ID", manageOfferOperation.offerId.description))
      }
      if let operationSourceAccountId = manageOfferOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is CreatePassiveOfferOperation.Type:
      let createPassiveOfferOperation = operation as! CreatePassiveOfferOperation
      data.append(("Selling", createPassiveOfferOperation.selling.code ?? "XLM"))
      if let sellIssuer = createPassiveOfferOperation.selling.issuer?.accountId, createPassiveOfferOperation.selling.code != nil {
        data.append(("Asset Issuer", sellIssuer.getTruncatedPublicKey()))
      }
      data.append(("Buying", createPassiveOfferOperation.buying.code ?? "XLM"))
      if let buyIssuer = createPassiveOfferOperation.buying.issuer?.accountId, createPassiveOfferOperation.buying.code != nil {
        data.append(("Asset Issuer", buyIssuer.getTruncatedPublicKey()))
      }
      data.append(("Amount", createPassiveOfferOperation.amount.description))
      data.append(("Price", getPrice(from: createPassiveOfferOperation.price)))
      if let operationSourceAccountId = createPassiveOfferOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is SetOptionsOperation.Type:
      let setOptionsOperation = operation as! SetOptionsOperation
      if let homeDomain = setOptionsOperation.homeDomain {
        data.append(("Home Domain", homeDomain))
      }
      if let masterKeyWeight = setOptionsOperation.masterKeyWeight {
        data.append(("Master Weight", masterKeyWeight.description))
      }
      if let lowThreshold = setOptionsOperation.lowThreshold {
        data.append(("Low Threshold", lowThreshold.description))
      }
      if let mediumThreshold = setOptionsOperation.mediumThreshold {
        data.append(("Medium Threshold", mediumThreshold.description))
      }
      if let highThreshold = setOptionsOperation.highThreshold {
        data.append(("High threshold", highThreshold.description))
      }
      if let signerWeight = setOptionsOperation.signerWeight {
        data.append(("Signer Weight", signerWeight.description))
      }
      if let x = setOptionsOperation.signer?.xdrEncoded, let s = try? PublicKey(xdr: x).accountId {
        data.append(("Signer Key", s.getTruncatedPublicKey()))
      }
      if let operationSourceAccountId = setOptionsOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
      // Set Flags / Clear Flags
    case is AllowTrustOperation.Type:
      let allowTrustOperation = operation as! AllowTrustOperation
      data.append(("Asset", allowTrustOperation.assetCode))
      data.append(("Trustor", allowTrustOperation.trustor.accountId.getTruncatedPublicKey()))
      data.append(("Authorize", allowTrustOperation.authorize.description))
      if let operationSourceAccountId = allowTrustOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is ChangeTrustOperation.Type:
      let changeTrustOperation = operation as! ChangeTrustOperation
      if let assetCode = changeTrustOperation.asset.code {
        data.append(("Asset", assetCode))
      }
      if let issuer = changeTrustOperation.asset.issuer?.accountId {
        data.append(("Asset Issuer", issuer.getTruncatedPublicKey()))
      }
      if let limit = changeTrustOperation.limit {
        data.append(("Limit", limit.description))
      }
      if let operationSourceAccountId = changeTrustOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is AccountMergeOperation.Type:
      let accountMergeOperation = operation as! AccountMergeOperation
      data.append(("Destination", accountMergeOperation.destinationAccountId.getTruncatedPublicKey()))
      tryToSetDestinationFederation(data: &data, destinationFederation: destinationFederation)
      if let operationSourceAccountId = accountMergeOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is ManageDataOperation.Type:
      let manageDataOperation = operation as! ManageDataOperation
      data.append(("Name", manageDataOperation.name))
      if let value = manageDataOperation.data {
        data.append(("Value", value.toUtf8String() ?? "none"))
      }
      if let operationSourceAccountId = manageDataOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    case is BumpSequenceOperation.Type:
      let bumpSequenceOperation = operation as! BumpSequenceOperation
      data.append(("Bump To", bumpSequenceOperation.bumpTo.description))
      if let operationSourceAccountId = bumpSequenceOperation.sourceAccountId, transactionSourceAccountId != operationSourceAccountId {
        data.append(("Operation Source", operationSourceAccountId.getTruncatedPublicKey()))
      }
      tryToSetOperationFields(data: &data, transactionSourceAccountId: transactionSourceAccountId, created: created, isListOperations: isListOperations)
    default:
      break
    }
    
    return data
  }
  
  static func tryToSetDestinationFederation(data: inout [(name: String, value: String)], destinationFederation: String) {
    if !destinationFederation.isEmpty {
      data.append(("Destination Federation", destinationFederation))
    }
  }
  
  static func tryToSetOperationFields(data: inout [(name: String, value: String)], transactionSourceAccountId: String, created: String?, isListOperations: Bool = false) {
    if !isListOperations {
      data.append(("Transaction Source", transactionSourceAccountId.getTruncatedPublicKey()))
    }
    if let created = created, !created.isEmpty {
      data.append(("Created", created))
    }
  }
  
  static func getPrice(from price: Price) -> String {
    let priceValue = Double(price.n) / Double(price.d)
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 7
    formatter.minimumIntegerDigits = 1
    
    return formatter.string(from: NSNumber(floatLiteral: priceValue)) ?? "unknown"
  }
  
  static func getNumberOfCharactersForTruncate() -> Int {
    switch UIDevice().type {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
      return 3
    default:
      return 6
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
  
  static func getTruncatedDomain(domain: inout String) -> String {
    if let range = domain.range(of: " auth") {
      domain.removeSubrange(range)
    }
    return domain
  }
}
