import Foundation
import stellarsdk

struct TransactionHelper {
  
  static func getListOfOperationNames(from xdr: String) throws -> [String] {
    
    guard let transactionXDR = try? TransactionXDR(xdr: xdr) else {
      throw VaultError.TransactionError.invalidTransaction
    }
  
    var operationNames: [String] = []
    
    for operation in transactionXDR.operations {
      let operationTypeValue = operation.body.type()
    
      let operationType = OperationType.init(rawValue: operationTypeValue)
    
      if let type = operationType {
        operationNames.append(type.description)
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
        guard let manageOfferOperation = operation as? ManageOfferOperation else {
          break
        }        
        guard let price = value as? Price else {
          break
        }
        
        var priceValue = Double(price.n) / Double(price.d)
        if manageOfferOperation.selling.type == AssetType.ASSET_TYPE_NATIVE {
          priceValue = 1 / priceValue
        }
        valueParam = String(format: "%.6f", priceValue)
      case is Decimal?.Type:
        valueParam = (value as? Decimal)?.description
      case is String.Type:
        valueParam = value
      case is String?.Type:
        valueParam = value
      case is Bool.Type:
        valueParam = (value as? Bool)?.description
//      case is SignerKeyXDR?.Type:
//        let signerKeyXDR = value as? SignerKeyXDR
//        let xdr = signerKeyXDR!.xdrEncoded
      default:
        continue
      }
      
      if let param = valueParam as? String {
        data.append((name, param))
      }
    }
    
    return data
  }
  
  static func getValidatedDate(from sourceDate: String) -> String {
    let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
    let outputDateFormat = "MMM dd, yyyy, HH:mm"
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = inputDateFormat
    
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
  
  static func getTransactionResultCode(from message: String) throws -> TransactionResultCode {
    guard let errorMessage = try? JSONDecoder().decode(HorizonErrorMessage.self,
                                                       from: message.data(using: String.Encoding.utf8)!) else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    guard let resultXDR = errorMessage.extras?.result_xdr else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let transactionResultXDR = try TransactionResultXDR(xdr: resultXDR)
    
    return transactionResultXDR.code
  }
}


