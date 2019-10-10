//

import UIKit

class SignersBottomTileTableViewCell: UITableViewCell {
  @IBOutlet var shadowView: UIView!
  @IBOutlet var infoContainerView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  
    shadowView.layer.shadowOpacity = 0.2
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
    shadowView.layer.shadowRadius = 4
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.masksToBounds = false
    
    infoContainerView.layer.borderWidth = 1
    infoContainerView.layer.cornerRadius = 5
    infoContainerView.layer.borderColor = UIColor.clear.cgColor
    infoContainerView.layer.masksToBounds = true
  }
}