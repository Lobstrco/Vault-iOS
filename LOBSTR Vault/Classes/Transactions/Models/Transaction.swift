import Foundation

enum ServerTransactionType: String, Codable {
  case authChallenge = "auth_challenge"
  case transaction
  case unknown
}

enum StatusType: Int, Codable {
  case pending = 1
  case cancelled = 2
  case signed = 3
}

struct Transaction: Codable {
  var hash: String?
  var xdr: String?
  var addedAt: String?
  var cancelledAt: String?
  var sequenceOutdatedAt: String?
  var signedAt: String?
  var status: StatusType?
  var getStatusDisplay: String?
  var transactionType: ServerTransactionType?
  var xdrSourceList: [String]?
  
  enum CodingKeys: String, CodingKey {
    case hash
    case xdr
    case addedAt = "added_at"
    case cancelledAt = "cancelled_at"
    case signedAt = "signed_at"
    case sequenceOutdatedAt = "sequence_outdated_at"
    case status
    case getStatusDisplay = "get_status_display"
    case transactionType = "transaction_type"
    case xdrSourceList = "xdr_source_list"
  }
}
