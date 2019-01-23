import Foundation
import UIKit

protocol BackUpAccountPresenter {
  func backUpAccountViewDidLoad()
  func understandButtonWasPressed()
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
}

// MARK: - Navigation

extension BackUpAccountPresenterImpl {
  func transitionToMnemenicGeneration() {
    let mnemonicGenerationViewController =
      MnemonicGenerationViewController.createFromStoryboard()
    navigationController.pushViewController(mnemonicGenerationViewController,
                                            animated: true)
  }
}
