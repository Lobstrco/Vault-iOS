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
  
  func copyToClipboardWasPressed()
  func nextButtondWasPressed()
  func configure(cell: MnemonicCollectionViewCell, forRow row: Int)
}

class MnemonicGenerationPresenterImpl: MnemonicGenerationPresenter {
  fileprivate weak var view: MnemonicGenerationView?
  
  var mnemonicList: [String] = []
  
  var numberOfMnemonicWords: Int {
    return mnemonicList.count
  }
  
  var mnemonicManager: MnemonicManager
  
  init(view: MnemonicGenerationView,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.mnemonicManager = mnemonicManager
    generateMnemonicList()
  }
  
  // MARK: - MnemonicGenerationPresenter
  
  func copyToClipboardWasPressed() {
    view?.copyToClipboard(mnemonic: MnemonicHelper.getStringFromSeparatedWords(in: mnemonicList))
  }
  
  func configure(cell: MnemonicCollectionViewCell, forRow row: Int) {
    cell.display(title: mnemonicList[row])
  }
  
  func nextButtondWasPressed() {
    transitionToMnemonicVerificationScreen()
  }
  
  // MARK: - Public Methods
  
  func transitionToMnemonicVerificationScreen() {
    guard let vc = MnemonicVerificationViewController.createFromStoryboard()
    else { fatalError() }
    vc.presenter.setGeneratedMnemonicList(generatedList: mnemonicList)
    
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.pushViewController(vc,
                                                                              animated: true)
  }
  
  func generateMnemonicList() {
    let mnemonicData = MnemonicHelper.get24WordMnemonic()
    mnemonicList = mnemonicData.separatedWords
    store(mnemonic: mnemonicData.mnemonic)
    view?.displayMnemonicList(mnemonicList: mnemonicList)
  }
}

private extension MnemonicGenerationPresenterImpl {
  private func store(mnemonic: String) {
    _ = mnemonicManager.encryptAndStoreInKeychain(mnemonic: mnemonic)
  }
}
