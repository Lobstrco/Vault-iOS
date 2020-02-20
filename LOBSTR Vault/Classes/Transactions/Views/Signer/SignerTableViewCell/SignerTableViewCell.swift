import UIKit

class SignerTableViewCell: UITableViewCell {

  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var identiconView: IdenticonView!
  @IBOutlet var publicAddressLabel: UILabel!
  @IBOutlet var federationLabel: UILabel!
  @IBOutlet var yourKeyTitleLabel: UILabel!
    
  func setData(viewData: SignerViewData) {
    identiconView.loadIdenticon(publicAddress: viewData.publicKey)
    
    statusLabel.text = viewData.statusText
    statusLabel.textColor = viewData.statusColor
    
    publicAddressLabel.text = viewData.publicKey.getTruncatedPublicKey(numberOfCharacters: 8)
    yourKeyTitleLabel.isHidden = !viewData.isLocalPublicKey
    
    guard let federation = viewData.federation else {
      yourKeyTitleLabel.text = "You"
      federationLabel.isHidden = true
      return
    }
    
    publicAddressLabel.font = UIFont.systemFont(ofSize: 13)
    publicAddressLabel.textColor = Asset.Colors.gray.color
    federationLabel.text = federation
    federationLabel.isHidden = false
  }
}
