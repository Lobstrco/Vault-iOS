import Foundation

struct HorizonErrorMessage: Decodable {
  let extras: Extras?
}

struct Extras: Decodable {
  let result_codes: ResultCodes?
  let result_xdr: String?
}

struct ResultCodes: Decodable {
  let transaction: String?
  let operations: [String]?
}
