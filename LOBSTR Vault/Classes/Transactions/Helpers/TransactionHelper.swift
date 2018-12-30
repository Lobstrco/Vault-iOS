import Foundation
import stellarsdk

struct TransactionHelper {
  
  static func getListOfOperationNames(from xdr: String) -> [String] {
    
    var operationNames: [String] = []
    
    do {
      let transactionXDR = try TransactionXDR(xdr: xdr)
      
      for operation in transactionXDR.operations {
        let operationType = operation.body.type()
        
        switch operationType {
        case OperationType.payment.rawValue:
          operationNames.append(String(describing: OperationType.payment))
        case OperationType.setOptions.rawValue:
          operationNames.append(String(describing: OperationType.setOptions))
        default:
          operationNames.append("none")
        }
      }
    } catch {
      print("Couldn't parse XDR")
    }
    
    return operationNames
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
}
