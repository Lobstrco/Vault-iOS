import Foundation

public struct SignedAccount: Codable {
  var address: String?
  
  var identiconURL: URL {
    let identiconURL = URL(string: "\(Constants.identiconBaseURL)\(address ?? "").png")!
    return identiconURL
  }
}
