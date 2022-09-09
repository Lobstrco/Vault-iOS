//

import Foundation
import UIKit

class HighlightedButton: UIButton {
  override var isHighlighted: Bool {
    didSet {
      backgroundColor = isHighlighted ? Asset.Colors.grayOpacity15.color : .clear
    }
  }
}
