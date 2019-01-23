import Foundation

public struct PaginationResponse<Element: Decodable>: Decodable {
  public var count: Int
  public var results: [Element]
  public var next: String?
  
  public init(results: [Element], next: String?, count: Int) {
    self.results = results
    self.next = next
    self.count = count
  }
  
  public func hasNextPage() -> Bool {
    return next != nil
  }
}
