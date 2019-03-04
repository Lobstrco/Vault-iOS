import Foundation

struct Transaction: Codable {
  var hash: String?
  var xdr: String?
  var addedAt: String?
  var cancelledAt: String?
  var sequenceOutdatedAt: String?
  var signedAt: String?
  var status: Int?
  var getStatusDisplay: String?
  
  enum CodingKeys: String, CodingKey {
    case hash
    case xdr
    case addedAt = "added_at"
    case cancelledAt = "cancelled_at"
    case signedAt = "signed_at"
    case sequenceOutdatedAt = "sequence_outdated_at"
    case status
    case getStatusDisplay = "get_status_display"
  }
}
