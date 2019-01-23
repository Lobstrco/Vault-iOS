import UIKit

class MnemonicVerificationViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicGeneration
  
  @IBOutlet var shuffledCollectionView: UICollectionView!
  @IBOutlet var сollectionViewForVerification: UICollectionView!
  
  @IBOutlet var errorLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  
  var presenter: MnemonicVerificationPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.mnemonicVerificationViewDidLoad()
    
    сollectionViewForVerification.dataSource = self
    сollectionViewForVerification.delegate = self
    
    setAppearance()
    setStaticStrings()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    setNextButton()
    AppearanceHelper.setBackButton(in: navigationController)
  }
  
  private func setNextButton() {
    let rightBarButtonItem = UIBarButtonItem.init(title: L10n.buttonTitleNext,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(nextButtonAction(_:)))
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem
  }
  
  @objc private func nextButtonAction(_ sender : UIButton) {
    presenter.nextButtonAction()
  }
  
  private func setStaticStrings() {
    descriptionLabel.text = L10n.textMnemonicVerificationDescription
    navigationItem.title = L10n.navTitleMnemonicVerification
  }
}

// MARK: - MnemonicVerificationView

extension MnemonicVerificationViewController: MnemonicVerificationView {
  
  func displayShuffledMnemonicList() {
    shuffledCollectionView.dataSource = self
    shuffledCollectionView.delegate = self
  }
  
  func updateCollectionViewForVerification() {
    сollectionViewForVerification.reloadData()
  }
  
  func updateShuffledCollectionView(by indexPath: IndexPath,
                                    color: UIColor) {
    shuffledCollectionView.cellForItem(at: indexPath)?.backgroundColor = color
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
      return CGSize(width: 65, height: 25)
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
      presenter.wordForVerificationWasPressed(with: indexPath)
    }
  }
}
