import UIKit
import PKHUD

class MnemonicGenerationViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicGeneration
  
  @IBOutlet var collectionView: UICollectionView!
  
  @IBOutlet var mnemonicDescriptionLabel: UILabel!
  @IBOutlet var copyDescriptionLabel: UILabel!
  @IBOutlet var confirmDescriptionLabel: UILabel!
  @IBOutlet var nextButton: UIButton!
  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  
  var presenter: MnemonicGenerationPresenter!
  
  private let heightOfCollectionViewFor12Words: CGFloat = 140
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    presenter.mnemonicGenerationViewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
    navigationController?.setNavigationBarAppearance(backgroundColor: Asset.Colors.background.color)
    presenter.mnemonicGenerationViewWillAppear()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
    navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
  }
  
  // MARK: - IBAction
  
  @IBAction func nextButtondAction() {
    presenter.nextButtondWasPressed()
  }
  
  @IBAction func copyToClipboardAction() {
    presenter.copyToClipboardWasPressed()
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  @IBAction func cancelButtonAcion() {
    presenter.cancelButtonWasPressed()    
  }
  
  @IBAction func helpButtonAcion() {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(nextButton, with: L10n.buttonTitleNext)
  }
  
  private func setCollectionViewAppearance() {
    heightConstraint.constant = presenter.numberOfMnemonicWords == 12 ?
      heightOfCollectionViewFor12Words : heightOfCollectionViewFor12Words * 2
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      AppearanceHelper.setDashBorders(for: self.collectionView, with: Asset.Colors.gray.color.cgColor)
    }
  }
  
  private func setStaticStrings() {
    mnemonicDescriptionLabel.text = L10n.textMnemonicDescription
    copyDescriptionLabel.text = L10n.textCopyDescription.replacingOccurrences(of: "[number]",
                                                                              with: String(presenter.numberOfMnemonicWords))
    confirmDescriptionLabel.text = L10n.textConfirmDescription
    navigationItem.title = L10n.navTitleMnemonicGeneration
  }
}

// MARK: - MnemonicGenerationView

extension MnemonicGenerationViewController: MnemonicGenerationView {
 
  func setMnemonicList(mnemonicList: [String]) {
    collectionView.dataSource = self
    collectionView.delegate = self
    
    setCollectionViewAppearance()
    setStaticStrings()
  }
  
  func copyToClipboard(mnemonic: String) {
    UIPasteboard.general.string = mnemonic
  }
  
  func setNextButton(isHidden: Bool) {
    nextButton.isHidden = isHidden
    confirmDescriptionLabel.isHidden = isHidden
  }
  
  func setNavigationItem() {
    navigationItem.largeTitleDisplayMode = .never
  }
  
  func setCancelAlert() {
    let alert = UIAlertController(title: L10n.cancelAlertMnemonicTitle, message: L10n.cancelAlertMnemonicMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .destructive, handler: { _ in
      self.presenter.cancelOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    present(alert, animated: true, completion: nil)
  }
  
  func setBackButton(isEnabled: Bool) {
    guard isEnabled else {
      navigationItem.hidesBackButton = true
      return
    }
    navigationItem.hidesBackButton = false
    navigationItem.leftBarButtonItem = nil
  }
  
  func setHelpButton(isEnabled: Bool) {
    navigationItem.rightBarButtonItem?.image = isEnabled ? Asset.Icons.Other.icQuestionSign.image : UIImage()
    navigationItem.rightBarButtonItem?.isEnabled = isEnabled
  }
  
  func showScreenshotTakenAlert() {
    UIAlertController.screenshotTakenAlert(presentingViewController: self)
  }
}


// MARK: - UICollection

extension MnemonicGenerationViewController: UICollectionViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return presenter.numberOfMnemonicWords
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicCollectionViewCell",
                                                  for: indexPath) as! MnemonicCollectionViewCell
    presenter.configure(cell: cell, forRow: indexPath.item)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width / 4 - 15, height: 35)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 12.0
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return false
  }
}
