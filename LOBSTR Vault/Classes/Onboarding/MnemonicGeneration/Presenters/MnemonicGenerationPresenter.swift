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
  func setBackButton(isEnabled: Bool)
  func setHelpButton(isEnabled: Bool)
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
  func helpButtonWasPressed()
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
  
  // MARK: - Private
  
  private func transitionToMnemonicVerificationScreen() {
    let mnemonicVerificationViewController = MnemonicVerificationViewController.createFromStoryboard()
    
    mnemonicVerificationViewController.presenter = MnemonicVerificationPresenterImpl(view: mnemonicVerificationViewController)
    mnemonicVerificationViewController.presenter.setGeneratedMnemonicList(generatedList: mnemonicList)
    
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.pushViewController(mnemonicVerificationViewController,
                                                                              animated: true)
  }
  
  private func generateMnemonicList() {
    let mnemonicData = MnemonicHelper.getWordMnemonic()
    mnemonicList = mnemonicData.separatedWords
    MnemonicHelper.encryptAndStoreInKeychain(mnemonic: mnemonicData.mnemonic)
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
    view?.setHelpButton(isEnabled: mnemonicMode == .generationMnemonic)
    
    switch mnemonicMode {
    case .generationMnemonic:
      generateMnemonicList()
      view?.setBackButton(isEnabled: false)
    case .showMnemonic:
      view?.setNavigationItem()
      view?.setBackButton(isEnabled: true)
      guard mnemonicManager.isMnemonicStoredInKeychain() else {
        return
      }
      
      mnemonicManager.getDecryptedMnemonicFromKeychain() { result in
        switch result {
        case .success(let mnemonic):
          self.mnemonicList = MnemonicHelper.getSeparatedWords(from: mnemonic)
          self.view?.setMnemonicList(mnemonicList: self.mnemonicList)
        case .failure(let error):
          Logger.mnemonic.error("Couldn't get decrypted mnemonic from keychain with error: \(error)")          
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
  
  func helpButtonWasPressed() {
    let helpViewController = ZendeskHelper.getZendeskArticleController(article: .recoveryPhrase)
    
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
  
  func cancelOperationWasConfirmed() {
    ApplicationCoordinatorHelper.clearKeychain()
    let mnemonicGenerationViewController = view as! MnemonicGenerationViewController
    mnemonicGenerationViewController.navigationController?.popToRootViewController(animated: true)
  }
}
