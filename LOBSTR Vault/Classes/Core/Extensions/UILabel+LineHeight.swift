import UIKit

extension UILabel {
    
  func setLineHeight(lineHeight: CGFloat) {
    let text = self.text
    if let text = text {
      let attributeString = NSMutableAttributedString(string: text)
      let style = NSMutableParagraphStyle()
      
      style.lineSpacing = lineHeight
      attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, text.count))
      self.attributedText = attributeString
    }
  }
}
