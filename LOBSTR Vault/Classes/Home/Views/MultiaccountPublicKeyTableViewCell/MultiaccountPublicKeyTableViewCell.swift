//

import UIKit

class MultiaccountPublicKeyTableViewCell: UITableViewCell {
  
  static let height: CGFloat = 76.0
  
  @IBOutlet var publicKeyTitleLabel: UILabel!
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var idenctionView: IdenticonView!
  @IBOutlet var checkboxImageView: UIImageView!
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    let image = selected ? Asset.Icons.Other.icCheckboxActive.image : Asset.Icons.Other.icCheckboxPassive.image
    checkboxImageView.image = image
  }
  
  func set(_ account: SignedAccount, index: Int) {
    let publicKeyIndex = index + 1
    if let nickName = account.nickname, !nickName.isEmpty {
      publicKeyTitleLabel.text = nickName
    } else {
      publicKeyTitleLabel.text = L10n.textVaultPublicKey + " " + publicKeyIndex.description
    }
    if let publicKey = account.address {
      publicKeyLabel.text = publicKey.getTruncatedPublicKey()
      idenctionView.loadIdenticon(publicAddress: publicKey)
    }
  }
}
