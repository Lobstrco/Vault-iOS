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
    
    var data: [(String, String)] = []
    
    let operationMirror = Mirror(reflecting: operation)
    for (name, value) in operationMirror.children {
      guard let name = name else { continue }
      
      var valueParam: Any?
      let valueType = type(of: value)
      
      switch valueType {
      case is KeyPair.Type:
        valueParam = (value as! KeyPair).accountId
//      case is Asset.Type:
//        valueParam = (value as! Asset).code ?? "XLM"
      case is Decimal.Type:
        valueParam = (value as! Decimal).description
      case is UInt32?.Type:
        valueParam = (value as? UInt32)?.description
      default:
        continue
      }
      
      if let ss = valueParam as? String {
        data.append((name, ss))
      }
    }
    
    return data
  }
  
  static func getValidatedDate(from sourceDate: String) -> String {
    let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
    let outputDateFormat = "MMM dd yyyy HH:mm a"
    
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
}

