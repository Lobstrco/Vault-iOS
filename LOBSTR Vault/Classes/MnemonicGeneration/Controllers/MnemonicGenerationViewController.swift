import UIKit

class MnemonicGenerationViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicGeneration
  
  @IBOutlet var collectionView: UICollectionView!
  
  @IBOutlet var mnemonicDescriptionLabel: UILabel!
  @IBOutlet var copyDescriptionLabel: UILabel!
  @IBOutlet var confirmDescriptionLabel: UILabel!
  
  @IBOutlet var nextButton: UIButton!
  
  var presenter: MnemonicGenerationPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    setStaticStrings()
    
    presenter = MnemonicGenerationPresenterImpl(view: self)
    presenter.mnemonicGenerationViewDidLoad()
  }
  
  // MARK: - IBAction
  
  @IBAction func nextButtondWasPressed() {
    presenter.nextButtondWasPressed()
  }
  
  @IBAction func copyToClipboard() {
    presenter.copyToClipboardWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(nextButton, with: L10n.buttonTitleNext)
    AppearanceHelper.setBackButton(in: navigationController)
  }
  
  private func setStaticStrings() {
    mnemonicDescriptionLabel.text = L10n.textMnemonicDescription
    copyDescriptionLabel.text = L10n.textCopyDescription
    confirmDescriptionLabel.text = L10n.textConfirmDescription
    navigationItem.title = L10n.navTitleMnemonicGeneration
  }
  
}

// MARK: - MnemonicGenerationView

extension MnemonicGenerationViewController: MnemonicGenerationView {
 
  func displayMnemonicList(mnemonicList: [String]) {
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  func copyToClipboard(mnemonic: String) {
    UIPasteboard.general.string = mnemonic
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
    return CGSize(width: 80, height: 35)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 2.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10.0
  }
}
