import Foundation

enum MnemonicMode {
  case generationMnemonic
  case showMnemonic
}

protocol MnemonicGenerationView: class {
  func setMnemonicList(mnemonicList: [String])
  func copyToClipboard(mnemonic: String)
  func setNextButton(isHidden: Bool)
  func setNavigationItem()
  func setCancelAlert()
}

protocol MnemonicCellView {
  var isSelected: Bool { get set }
  func set(title: String)
}

protocol MnemonicGenerationPresenter {
  var numberOfMnemonicWords: Int { get }
  
  func mnemonicGenerationViewDidLoad()
  func copyToClipboardWasPressed()
  func nextButtondWasPressed()
  func cancelButtonWasPressed()
  func configure(cell: MnemonicCollectionViewCell, forRow row: Int)
  func cancelOperationWasConfirmed()
}

class MnemonicGenerationPresenterImpl {
  fileprivate weak var view: MnemonicGenerationView?
  
  var mnemonicList: [String] = []
  var mnemonicManager: MnemonicManager
  var mnemonicMode: MnemonicMode
  
  // MARK: - Init
  
  init(view: MnemonicGenerationView,
       mnemonicMode: MnemonicMode,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.mnemonicMode = mnemonicMode
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
    view?.setMnemonicList(mnemonicList: mnemonicList)
  }
}

// MARK: - MnemonicGenerationPresenter

extension MnemonicGenerationPresenterImpl: MnemonicGenerationPresenter {
  
  var numberOfMnemonicWords: Int {
    return mnemonicList.count
  }
  
  func mnemonicGenerationViewDidLoad() {
    view?.setNextButton(isHidden: mnemonicMode == .showMnemonic)
    
    switch mnemonicMode {
    case .generationMnemonic:
      generateMnemonicList()
    case .showMnemonic:
      view?.setNavigationItem()
      guard mnemonicManager.isMnemonicStoredInKeychain() else {
        return
      }
      
      mnemonicManager.getDecryptedMnemonicFromKeychain() { result in
        switch result {
        case .success(let mnemonic):
          self.mnemonicList = MnemonicHelper.getSeparatedWords(from: mnemonic)
          self.view?.setMnemonicList(mnemonicList: self.mnemonicList)
        case .failure(let error):
          print("error: \(error)")
        }
      }
    }
    
  }
  
  func copyToClipboardWasPressed() {
    view?.copyToClipboard(mnemonic: MnemonicHelper.getStringFromSeparatedWords(in: mnemonicList))
  }
  
  func configure(cell: MnemonicCollectionViewCell, forRow row: Int) {
    cell.set(title: mnemonicList[row])
  }
  
  func nextButtondWasPressed() {
    transitionToMnemonicVerificationScreen()
  }
  
  func cancelButtonWasPressed() {
    view?.setCancelAlert()
  }
  
  func cancelOperationWasConfirmed() {
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.popToRootViewController(animated: true)
  }
}

private extension MnemonicGenerationPresenterImpl {
  private func store(mnemonic: String) {
    _ = mnemonicManager.encryptAndStoreInKeychain(mnemonic: mnemonic)
  }
}
