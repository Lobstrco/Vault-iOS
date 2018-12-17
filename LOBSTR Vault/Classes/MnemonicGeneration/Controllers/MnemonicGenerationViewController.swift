import UIKit

class MnemonicGenerationViewController: UIViewController, MnemonicGenerationView,
MnemonicGenerationStoryboardCreation {
  @IBOutlet var collectionView: UICollectionView!
  var presenter: MnemonicGenerationPresenter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = MnemonicGenerationPresenterImpl(view: self)
  }
  
  // MARK: - IBAction
  
  @IBAction func nextButtondWasPressed() {
    presenter.nextButtondWasPressed()
  }  
  
  @IBAction func copyToClipboard() {
    presenter.copyToClipboardWasPressed()
  }
  
  // MARK: - MnemonicGenerationView
  
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
