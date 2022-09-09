//

import Foundation

public enum BeautifulMemo {
  case text(String)
  case id(String)
  case returnHash(String)
  case hash(String)
  case none
  
  var title: String {
    switch self {
    case .text: return "Memo (text)"
    case .id: return "Memo (id)"
    case .returnHash: return "Memo (return)"
    case .hash: return "Memo (hash)"
    case .none: return ""
    }
  }
  
  var value: String {
    switch self {
    case .text(let string): return string
    case .id(let string): return string
    case .returnHash(let string): return string
    case .hash(let string): return string
    case .none: return ""
    }
  }
}
