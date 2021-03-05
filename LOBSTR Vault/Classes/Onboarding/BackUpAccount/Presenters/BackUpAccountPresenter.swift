import Foundation
import UIKit

protocol BackUpAccountPresenter {
  func backUpAccountViewDidLoad()
  func understandButtonWasPressed()
  func helpButtonWasPressed()
}

class BackUpAccountPresenterImpl: BackUpAccountPresenter {
  private weak var view: BackUpAccountView?
  private let navigationController: UINavigationController
  
  
  init(view: BackUpAccountView, navigationController: UINavigationController) {
    self.view = view
    self.navigationController = navigationController
  }
  
  // MARK: - BackUpAccountPresenter
  
  func backUpAccountViewDidLoad() {
    
  }
  
  func understandButtonWasPressed() {
    transitionToMnemenicGeneration()
  }
  
  func helpButtonWasPressed() {
    let helpViewController = ZendeskHelper.getZendeskArticleController(article: .recoveryPhrase)
    
    let backupViewController = view as! BackUpAccountViewController
    backupViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
}

// MARK: - Navigation

extension BackUpAccountPresenterImpl {
  func transitionToMnemenicGeneration() {
    let mnemonicGenerationViewController = MnemonicGenerationViewController.createFromStoryboard()
    mnemonicGenerationViewController.presenter = MnemonicGenerationPresenterImpl(view: mnemonicGenerationViewController,
                                                                                 mnemonicMode: .generationMnemonic)
    navigationController.pushViewController(mnemonicGenerationViewController, animated: true)
  }
}
