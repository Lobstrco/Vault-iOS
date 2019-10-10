//

import UIKit

class SignerTableViewCell: UITableViewCell {

  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var identiconView: IdenticonView!
  @IBOutlet var publicAddressLabel: UILabel!
    
  func setData(viewData: SignerViewData) {
    identiconView.loadIdenticon(publicAddress: viewData.publicKey)
    
    statusLabel.text = viewData.statusText
    statusLabel.textColor = viewData.statusColor
    publicAddressLabel.text = viewData.publicKey
  }
  
}
