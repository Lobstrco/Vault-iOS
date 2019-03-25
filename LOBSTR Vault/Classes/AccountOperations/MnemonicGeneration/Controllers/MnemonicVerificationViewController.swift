import UIKit

class MnemonicVerificationViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicGeneration
  
  @IBOutlet var containerForVerification: UIView!
  
  @IBOutlet var shuffledCollectionView: UICollectionView!
  @IBOutlet var сollectionViewForVerification: UICollectionView!
  
  @IBOutlet var errorLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var clearButton: UIButton!
  @IBOutlet var nextButton: UIButton!
  
  var presenter: MnemonicVerificationPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    shuffledCollectionView.allowsMultipleSelection = true  
    сollectionViewForVerification.dataSource = self
    сollectionViewForVerification.delegate = self
    
    setStaticStrings()
    
    presenter.mnemonicVerificationViewDidLoad()
  }
  
  override func viewDidLayoutSubviews() {
    AppearanceHelper.setDashBorders(for: containerForVerification, with: Asset.Colors.gray.color.cgColor)
  }
  
  // MARK: - IBAction
  
  @IBAction func clearButtondAction() {
    presenter.clearButtonWasPressed()
  }
  
  @IBAction func nextButtonAction() {
    presenter.nextButtonWasPressed()
  }
  
  @IBAction func helpButtonAcion() {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setStaticStrings() {
    descriptionLabel.text = L10n.textMnemonicVerificationDescription
    navigationItem.title = L10n.navTitleMnemonicVerification
    errorLabel.text = L10n.textMnemonicVerifivationIncorrectOrder
  }
}

// MARK: - MnemonicVerificationView

extension MnemonicVerificationViewController: MnemonicVerificationView {
  
  func setShuffledMnemonicList() {
    shuffledCollectionView.dataSource = self
    shuffledCollectionView.delegate = self
  }
  
  func updateCollectionViewForVerification() {
    сollectionViewForVerification.reloadData()
  }
  
  func setErrorLabel(isHidden: Bool) {
    errorLabel.isHidden = isHidden
  }
  
  func setDashBordersColor(isError: Bool) {
    let bordersColor = isError ? Asset.Colors.red.color.cgColor : Asset.Colors.gray.color.cgColor
    AppearanceHelper.changeDashBorderColor(for: containerForVerification, with: bordersColor)
  }
  
  func setNextButtonStatus(isEnabled: Bool) {
    var backgorundColor = Asset.Colors.main.color
    if !isEnabled {
      backgorundColor = Asset.Colors.disabled.color
    }
    
    nextButton.backgroundColor = backgorundColor
    nextButton.isEnabled = isEnabled
  }
  
  func setClearButtonStatus(isEnabled: Bool) {
    clearButton.isHidden = !isEnabled
  }
}

// MARK: - UICollection

extension MnemonicVerificationViewController: UICollectionViewDelegate, UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    if collectionView == shuffledCollectionView {
      return presenter.countOfShuffledMnemonicList
    } else {
      return presenter.countOfMnemonicListForVerification
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == shuffledCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicCollectionViewCell",
                                                    for: indexPath) as! MnemonicCollectionViewCell
      presenter.configureShuffled(cell, forRow: indexPath.item)
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicVerificationCollectionViewCell",
                                                    for: indexPath) as! MnemonicCollectionViewCell
      presenter.configure(cellForVerification: cell, forRow: indexPath.item)
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == shuffledCollectionView {
      return CGSize(width: 80, height: 35)
    } else {
      return CGSize(width: 70, height: 35)
    }
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
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == shuffledCollectionView {
      presenter.shuffledWordWasPressed(with: indexPath)
    } else {
      let newIndexPath = presenter.getIndexPathFromShuffledMnemonicList(by: indexPath.item)
      shuffledCollectionView.deselectItem(at: newIndexPath, animated: false)
      presenter.wordForVerificationWasPressed(with: indexPath)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func deselectShuffledCollectionView() {
    for index in 0...presenter.countOfShuffledMnemonicList {
      shuffledCollectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
    }
  }
}
