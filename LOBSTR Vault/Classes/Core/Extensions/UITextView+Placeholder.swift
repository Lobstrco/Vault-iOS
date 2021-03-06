import UIKit

extension UITextView: UITextViewDelegate {
  
  override open var bounds: CGRect {
    didSet {
      self.resizePlaceholder()
    }
  }
  
  public var placeholder: String? {
    get {
      var placeholderText: String?
      
      if let placeholderLabel = self.viewWithTag(100) as? UILabel {
        placeholderText = placeholderLabel.text
      }
      
      return placeholderText
    }
    set {
      if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
        placeholderLabel.text = newValue
        placeholderLabel.sizeToFit()
      } else {
        self.addPlaceholder(newValue!)
      }
    }
  }
  
  public func textViewDidChange(_ textView: UITextView) {
    if let placeholderLabel = self.viewWithTag(100) as? UILabel {
      placeholderLabel.isHidden = self.text.count > 0
    }
  }
  
  // MARK: - Private
  
  private func resizePlaceholder() {
    if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
      let labelX = self.textContainer.lineFragmentPadding + 20
      let labelY = self.textContainerInset.top + 10
      let labelWidth = self.frame.width - (labelX * 2)
      let labelHeight = placeholderLabel.frame.height
      
      placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
    }
  }
  
  private func addPlaceholder(_ placeholderText: String) {
    let placeholderLabel = UILabel()
    
    placeholderLabel.text = placeholderText
    placeholderLabel.sizeToFit()
    
    placeholderLabel.font = self.font
    placeholderLabel.textColor = UIColor.lightGray
    placeholderLabel.tag = 100
    
    placeholderLabel.isHidden = self.text.count > 0
    
    self.addSubview(placeholderLabel)
    self.resizePlaceholder()
    self.delegate = self
  }
}

extension UITextView {
  func centerVertically(text: String) {
    var top: CGFloat = 0.0
    if text.isEmpty {
      top = (self.bounds.size.height - self.contentSize.height * self.zoomScale)
    } else {
      top = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
    }
    top = top < 0.0 ? 0.0 : top
    self.contentInset.top = top
  }
}
