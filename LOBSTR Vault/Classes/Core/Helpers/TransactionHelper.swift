import Foundation
import stellarsdk

struct TransactionHelper {
  
  static func getListOfOperationNames(from transactionXDR: TransactionXDR) throws -> [String] {
    var operationNames: [String] = []
    
    for operation in transactionXDR.operations {
      let operationTypeValue = operation.body.type()
    
      let operationType = OperationType.init(rawValue: operationTypeValue)
    
      if let type = operationType {
        var name = "unknown"
        switch type {
        case .accountCreated:
          name = "Create Account"
        default:
          name = type.description
        }
        
        operationNames.append(name)
      }
    }
    
    return operationNames
  }
  
  static func getOperation(from xdr: String, by index: Int) throws -> stellarsdk.Operation {
    
    guard let transactionXDR = try? TransactionXDR(xdr: xdr) else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard transactionXDR.operations.count > index else {
      throw VaultError.TransactionError.outOfOperationRange
    }
    
    let operationXDR = transactionXDR.operations[index]
    
    guard let operation = try? Operation.fromXDR(operationXDR: operationXDR) else {
      throw VaultError.OperationError.invalidOperation
    }
    
    return operation
  }
  
  static func getNamesAndValuesOfProperties(from operation: stellarsdk.Operation) -> [(String, String)] {
    var data: [(name: String, value: String)] = []
    
    if let manageOfferOperation = operation as? ManageOfferOperation {
      data.append(("selling", manageOfferOperation.selling.code ?? "XLM"))
      data.append(("buying", manageOfferOperation.buying.code ?? "XLM"))
      data.append(("amount", manageOfferOperation.amount.description))
      data.append(("price", TransactionHelper.getPrice(from: manageOfferOperation)))
      data.append(("offerId", manageOfferOperation.offerId.description))
      return data
    }
    
    let operationMirror = Mirror(reflecting: operation)
    for (name, value) in operationMirror.children {
      guard let name = name else { continue }
      
      var valueParam: Any?
      let valueType = type(of: value)
      
      switch valueType {
      case is KeyPair.Type:
        valueParam = (value as? KeyPair)?.accountId
      case is KeyPair?.Type:
        valueParam = (value as? KeyPair)?.accountId
      case is stellarsdk.Asset.Type:
        valueParam = (value as? stellarsdk.Asset)?.code ?? "XLM"
      case is Decimal.Type:
        valueParam = (value as? Decimal)?.description
      case is UInt32?.Type:
        valueParam = (value as? UInt32)?.description
      case is UInt64.Type:
        valueParam = (value as? UInt64)?.description
      case is Price.Type:
        break
      case is Decimal?.Type:
        valueParam = (value as? Decimal)?.description
      case is String.Type:
        valueParam = value
      case is String?.Type:
        valueParam = value
      case is Bool.Type:
        valueParam = (value as? Bool)?.description
      default:
        continue
      }
      
      if let param = valueParam as? String {
        data.append((name, param))
      }
    }
    
    return data
  }
  
  static func getPrice(from operation: ManageOfferOperation) -> String {
    let priceValue = Double(operation.price.n) / Double(operation.price.d)
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 7
    
    return formatter.string(from: NSNumber(floatLiteral: priceValue)) ?? "unknown"
  }
  
  static func getValidatedDate(from sourceDate: String) -> String {
    let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
    let outputDateFormat = "MMM d, yyyy, HH:mm"
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = inputDateFormat
    dateFormatterGet.locale = Locale(identifier: "en_US")
    
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = outputDateFormat
    
    if let date = dateFormatterGet.date(from: sourceDate) {
      return dateFormatterPrint.string(from: date)
    } else {
      return "none"
    }
  }
  
  static func signTransaction(transactionEnvelopeXDR: TransactionEnvelopeXDR, userKeyPair: KeyPair) -> String? {
    let envelopeXDR = transactionEnvelopeXDR
    do {
      let tx = envelopeXDR.tx
      
      // user signature
      let transactionHash = try [UInt8](tx.hash(network: .public))
      let userSignature = userKeyPair.signDecorated(transactionHash)
      
      envelopeXDR.signatures.append(userSignature)
      
      if let xdrEncodedEnvelope = envelopeXDR.xdrEncoded {
        return xdrEncodedEnvelope
      } else {
        return nil
      }
    } catch _ {
      return nil
    }
  }
  
  static func signTransaction(transactionEnvelopeXDR: TransactionEnvelopeXDR,
                              mnemonicManager: MnemonicManager,
                              completion: @escaping (Result<String>) -> Void) {
    
    guard mnemonicManager.isMnemonicStoredInKeychain() else {
      return
    }
    
    mnemonicManager.getDecryptedMnemonicFromKeychain { result in
      switch result {
      case .success(let mnemonic):
        let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic)
        guard let transactionEnvelope = TransactionHelper.signTransaction(transactionEnvelopeXDR: transactionEnvelopeXDR,
                                                                          userKeyPair: keyPair)
        else {
          completion(.failure(VaultError.TransactionError.invalidTransaction))
          return
        }
        
        completion(.success(transactionEnvelope))
      case .failure(let error):
        completion(.failure(error))
      }
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
}


