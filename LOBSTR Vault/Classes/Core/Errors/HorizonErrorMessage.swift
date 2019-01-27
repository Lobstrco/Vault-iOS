import Foundation

struct HorizonErrorMessage: Decodable {
  let extras: Extras?
}

struct Extras: Decodable {
  let result_codes: ResultCodes?
}

struct ResultCodes: Decodable {
  let transaction: String?
}
