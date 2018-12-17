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
  
  init(view: MnemonicGenerationView) {
    self.view = view
    
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
    guard let vc = MnemonicVerificationViewController.createFromStoryboard() else { fatalError() }
    vc.presenter.setGeneratedMnemonicList(generatedList: mnemonicList)
    
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.pushViewController(vc, animated: true)
  }
  
  func generateMnemonicList() {
    mnemonicList = MnemonicHelper.getSeparated24WordMnemonic()
    view?.displayMnemonicList(mnemonicList: mnemonicList)
  }
}
