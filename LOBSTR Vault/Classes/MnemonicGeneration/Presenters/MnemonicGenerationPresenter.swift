import Foundation

protocol MnemonicGenerationView: class {
  func displayMnemonicList(mnemonicList: [String])
  func copyToClipboard(mnemonic: String)
}

protocol MnemonicCellView {
  func display(title: String)
}

protocol MnemonicGenerationPresenter {
  var numberOfMnemonicWords: Int { get }
  
  func mnemonicGenerationViewDidLoad()
  func copyToClipboardWasPressed()
  func nextButtondWasPressed()
  func configure(cell: MnemonicCollectionViewCell, forRow row: Int)
}

class MnemonicGenerationPresenterImpl {
  fileprivate weak var view: MnemonicGenerationView?
  
  var mnemonicList: [String] = []
  var mnemonicManager: MnemonicManager
  
  // MARK: - Init
  
  init(view: MnemonicGenerationView,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.mnemonicManager = mnemonicManager
  }
  
  // MARK: - Public Methods
  
  func transitionToMnemonicVerificationScreen() {
    let mnemonicVerificationViewController = MnemonicVerificationViewController.createFromStoryboard()
    
    mnemonicVerificationViewController.presenter = MnemonicVerificationPresenterImpl(view: mnemonicVerificationViewController)
    mnemonicVerificationViewController.presenter.setGeneratedMnemonicList(generatedList: mnemonicList)
    
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.pushViewController(mnemonicVerificationViewController,
                                                                              animated: true)
  }
  
  func generateMnemonicList() {
    let mnemonicData = MnemonicHelper.getWordMnemonic()
    mnemonicList = mnemonicData.separatedWords
    store(mnemonic: mnemonicData.mnemonic)
    view?.displayMnemonicList(mnemonicList: mnemonicList)
  }
}

// MARK: - MnemonicGenerationPresenter

extension MnemonicGenerationPresenterImpl: MnemonicGenerationPresenter {
  
  var numberOfMnemonicWords: Int {
    return mnemonicList.count
  }
  
  func mnemonicGenerationViewDidLoad() {
    generateMnemonicList()
  }
  
  func copyToClipboardWasPressed() {
    view?.copyToClipboard(mnemonic: MnemonicHelper.getStringFromSeparatedWords(in: mnemonicList))
  }
  
  func configure(cell: MnemonicCollectionViewCell, forRow row: Int) {
    cell.display(title: mnemonicList[row])
  }
  
  func nextButtondWasPressed() {
    transitionToMnemonicVerificationScreen()
  }
}

private extension MnemonicGenerationPresenterImpl {
  private func store(mnemonic: String) {
    _ = mnemonicManager.encryptAndStoreInKeychain(mnemonic: mnemonic)
  }
}
