import UIKit
import PKHUD

class MultisigInfoViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .home
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var actionButton: UIButton!
  
  @IBOutlet var firstOptionView: UIView!
  @IBOutlet var secondOptionView: UIView!
  
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var closeButton: UIButton!
  
  var publicKey: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
                    
    setAppearance()
    publicKeyLabel.text = publicKey.getTruncatedPublicKey()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    switch LobstrCheckerImpl().checkLobstr() {
    case .installed:
      titleLabel.text = "Use Vault with LOBSTR on this device"
        descriptionLabel.text = "Open LOBSTR to add this device as a signer for your Stellar account and use advanced multisignature capabilities."
        actionButton.setTitle("Open LOBSTR Wallet", for: .normal)
    case .notInstalled:
      titleLabel.text = "Install LOBSTR wallet"
      descriptionLabel.text = "Vault signer app works best with LOBSTR wallet. Install LOBSTR to enable multisig and use advanced features."
      actionButton.setTitle("Download LOBSTR", for: .normal)
    }
  }
  
  @IBAction func openLobstrButtonAction(_ sender: Any) {
    switch LobstrCheckerImpl().checkLobstr() {
    case .installed:
      if let url = URL(string: Constants.lobstrMultisigScheme), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      }
    case .notInstalled:
      if let url = URL(string: Constants.lobstrAppStoreLink) {
        UIApplication.shared.open(url)
      }
    }
  }

  @IBAction func copyPublicKeyButtonAction(_ sender: Any) {
    UIPasteboard.general.string = publicKey
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  @IBAction func closeButtonAction(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func showQRCodeButtonDidPress(_ sender: Any) {
    let publicKeyView = Bundle.main.loadNibNamed(PublicKeyPopover.nibName,
                                                 owner: view,
                                                 options: nil)?.first as! PublicKeyPopover
    publicKeyView.initData()
    
    let popoverHeight: CGFloat = UIScreen.main.bounds.height / 2.2
    let popover = CustomPopoverViewController(height: popoverHeight, view: publicKeyView)
    publicKeyView.popoverDelegate = popover
    
    present(popover, animated: true, completion: nil)
  }
}

private extension MultisigInfoViewController {
  func setAppearance() {
     AppearanceHelper.set(closeButton, with: L10n.buttonTitleDone)
     setAppearance(for: firstOptionView)
     setAppearance(for: secondOptionView)
   }
   
   func setAppearance(for containerView: UIView) {
     
     guard let childView = containerView.subviews.first else { return }
     
     childView.layer.borderWidth = 1
     childView.layer.cornerRadius = 5
     childView.layer.borderColor = UIColor.clear.cgColor
     childView.layer.masksToBounds = true
     
     containerView.layer.shadowOpacity = 0.2
     containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
     containerView.layer.shadowRadius = 4
     containerView.layer.shadowColor = UIColor.black.cgColor
     containerView.layer.masksToBounds = false
   }
}

