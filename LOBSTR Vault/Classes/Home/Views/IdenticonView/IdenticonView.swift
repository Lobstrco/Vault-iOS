import UIKit
import Kingfisher

class IdenticonView: UIView {
  
  var view: UIView!
  
  @IBOutlet var imageView: UIImageView!

  // MARK: - Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    xibSetup()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    layer.cornerRadius = bounds.height / 2
    layer.borderWidth = 1
    layer.borderColor = Asset.Colors.identiconBorder.color.cgColor
    clipsToBounds = true
  }
  
  // MARK: - Public
  
  public func loadIdenticon(publicAddress: String) {
    imageView.kf.setImage(with: SignedAccount(address: publicAddress).identiconURL,
                          placeholder: Asset.Icons.Other.icIdenticonPlaceholder.image)
  }
  
  // MARK: - Private
  
  private func xibSetup() {
    view = loadViewFromNib()
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    addSubview(view)
  }
  
  private func loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: IdenticonView.nibName,
                    bundle: bundle)
    let view = nib.instantiate(withOwner: self,
                               options: nil).first as! UIView
    return view
  }
}
