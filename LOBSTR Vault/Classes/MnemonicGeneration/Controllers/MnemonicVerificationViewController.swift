import UIKit

class MnemonicVerificationViewController: UIViewController, MnemonicVerificationView, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicGeneration
  
  @IBOutlet var shuffledCollectionView: UICollectionView!
  @IBOutlet var сollectionViewForVerification: UICollectionView!
  
  var presenter: MnemonicVerificationPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.mnemonicVerificationViewDidLoad()
    
    сollectionViewForVerification.dataSource = self
    сollectionViewForVerification.delegate = self
  }
  
  // MARK: - IBAction
  
  @IBAction func nextButtonAction(_ sender: Any) {
    presenter.nextButtonAction()
  }
  
  // MARK: - MnemonicVerificationView
  
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
