import UIKit

protocol SignersTotalNumberTableViewCellDelegate: AnyObject {
  func numberOfSignerButtonDidPress()
}

class SignersTotalNumberTableViewCell: UITableViewCell {

  @IBOutlet var shadowView: UIView!
  @IBOutlet var infoContainerView: UIView!
  @IBOutlet var signerTotalNumberButton: UIButton!
  @IBOutlet var accountLabel: UILabel!
  
  weak var delegate: SignersTotalNumberTableViewCellDelegate?
  
  override func layoutSubviews() {
    
    shadowView.layer.shadowOpacity = 0.2
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
    shadowView.layer.shadowRadius = 4
    shadowView.layer.shadowColor = UIColor.black.cgColor
    
    infoContainerView.layer.borderWidth = 1
    infoContainerView.layer.cornerRadius = 5
    infoContainerView.layer.borderColor = UIColor.clear.cgColor
    infoContainerView.layer.masksToBounds = true
    
    super.layoutSubviews()
  }
  
  @IBAction func numberOfSignerButtonAction(_ sender: UIButton) {
    delegate?.numberOfSignerButtonDidPress()
  }
}

extension UIView {
  func roundCorners(corners: UIRectCorner,
                    radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds,
                            byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
