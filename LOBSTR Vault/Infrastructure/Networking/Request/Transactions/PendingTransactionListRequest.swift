import Foundation

struct PendingTransactionListRequestParameters {
  let page: String?
}

struct PendingTransactionListRequest: APIRequest {

  func makeRequest(from data: PendingTransactionListRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/transactions/pending/"
    let urlString = Environment.baseURL + path
    var urlComponents = URLComponents(string: urlString)!

    if let page = data?.page {
      urlComponents.queryItems = [URLQueryItem(name: "page", value: page)]
    }
    
    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = APIRequestHTTPMethod.get.rawValue
    
    if let token = jwtToken {
      let autrhorizationHeaderField = "Authorization"
      urlRequest.addValue("JWT \(token)", forHTTPHeaderField: autrhorizationHeaderField)
    }
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

    return urlRequest
  }

  func parseResponse(data: Data) throws -> PaginationResponse<Transaction> {
    return try JSONDecoder().decode(PaginationResponse<Transaction>.self, from: data)
  }

}
