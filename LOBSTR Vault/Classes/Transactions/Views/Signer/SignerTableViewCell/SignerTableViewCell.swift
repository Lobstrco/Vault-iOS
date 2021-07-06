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
    
    publicAddressLabel.text = viewData.publicKey.getTruncatedPublicKey()
    yourKeyTitleLabel.isHidden = !viewData.isLocalPublicKey
    
    
    var nicknameValue = ""
    var federationValue = ""
    
    if let nickName = viewData.nickname, !nickName.isEmpty {
      nicknameValue = nickName
    } else {
      if let federation = viewData.federation, !federation.isEmpty {
        federationValue = federation
      } else {
        if viewData.isLocalPublicKey {
          publicAddressLabel.font = UIFont.systemFont(ofSize: 13)
          publicAddressLabel.textColor = Asset.Colors.gray.color
        }
        yourKeyTitleLabel.text = "Your Vault account"
        federationLabel.isHidden = true
        return
      }
    }
    
    let text = !nicknameValue.isEmpty ? nicknameValue : federationValue
    
    publicAddressLabel.font = UIFont.systemFont(ofSize: 13)
    publicAddressLabel.textColor = Asset.Colors.gray.color
    federationLabel.text = text
    federationLabel.isHidden = false
  }
}
