import Foundation
import UIKit

protocol MnemonicVerificationView: class {
  func setShuffledMnemonicList()
  func updateCollectionViewForVerification()
//  func setRightBarButton(isEnabled: Bool)
  func setErrorLabel(isHidden: Bool)
  func setDashBordersColor(isError: Bool)
  func deselectShuffledCollectionView()
  func setNextButtonStatus(isEnabled: Bool)
}

protocol MnemonicVerificationPresenter {
  var countOfShuffledMnemonicList: Int { get }
  var countOfMnemonicListForVerification: Int { get }
  var getShuffledMnemonicList: [String] { get }
  var getMnemonicListForVerification: [String] { get }
  func mnemonicVerificationViewDidLoad()
  func setGeneratedMnemonicList(generatedList: [String])
  func shuffledWordWasPressed(with indexPath: IndexPath)
  func wordForVerificationWasPressed(with indexPath: IndexPath)
  func configureShuffled(_ cell: MnemonicCellView, forRow row: Int)
  func configure(cellForVerification: MnemonicCellView, forRow row: Int)
  func nextButtonWasPressed()
  func getIndexPathFromShuffledMnemonicList(by index: Int) -> IndexPath
  func clearButtonWasPressed()
  func helpButtonWasPressed()
}

class MnemonicVerificationPresenterImpl {
  fileprivate weak var view: MnemonicVerificationView?
  fileprivate var generatedMnemonicList: [String] = []
  fileprivate var shuffledMnemonicList: [String] = []
  fileprivate var mnemonicListForVerification: [String] = []
  
  fileprivate weak var crashlyticsService: CrashlyticsService?
  
  fileprivate let numberWordsInMnemonic = 12
  
  // MARK: - Init
  
  init(view: MnemonicVerificationView, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
  }
  
  // MARK: - Public
  
  func initShuffledMnemonicList() {
    guard !generatedMnemonicList.isEmpty else { return }
    
    shuffledMnemonicList = generatedMnemonicList.shuffled()
    view?.setShuffledMnemonicList()
  }
  
  func clearWordsForVerification() {
    mnemonicListForVerification.removeAll()
    view?.updateCollectionViewForVerification()
  }
  
  func moveShuffledWordToListForVerification(by indexPath: IndexPath) {
    mnemonicListForVerification.append(shuffledMnemonicList[indexPath.item])
    view?.updateCollectionViewForVerification()
  }
  
  func moveWordForVerificationToShuffledMnemonicList(by indexPath: IndexPath) {
    mnemonicListForVerification.remove(at: indexPath.item)
    view?.updateCollectionViewForVerification()
  }
  
  func validateVerificationList() {
    guard mnemonicListForVerification.count == numberWordsInMnemonic else {
      view?.setNextButtonStatus(isEnabled: false)
      view?.setErrorLabel(isHidden: true)
      view?.setDashBordersColor(isError: false)
      return
    }
    
    if mnemonicListForVerification == generatedMnemonicList {
      view?.setNextButtonStatus(isEnabled: true)
    } else {
      view?.setNextButtonStatus(isEnabled: false)
      view?.setErrorLabel(isHidden: false)
      view?.setDashBordersColor(isError: true)
    }
  }
  
  func transitionToPinScreen() {
    let pinViewController = PinViewController.createFromStoryboard()
    
    pinViewController.mode = .createPinFirstStep
    
    let mnemonicVerificationViewController =
      view as! MnemonicVerificationViewController
    mnemonicVerificationViewController.navigationController?
      .pushViewController(pinViewController,
                          animated: true)
  }
}

// MARK: - MnemonicVerificationPresenter

extension MnemonicVerificationPresenterImpl: MnemonicVerificationPresenter {
  
  var countOfMnemonicListForVerification: Int {
    return mnemonicListForVerification.count
  }

  func getIndexPathFromShuffledMnemonicList(by index: Int) -> IndexPath {
    let indexInShuffledList =
      shuffledMnemonicList.firstIndex(of: mnemonicListForVerification[index])
    return IndexPath(item: indexInShuffledList!, section: 0)
  }
  
  var countOfShuffledMnemonicList: Int {
    return shuffledMnemonicList.count
  }
  
  var getShuffledMnemonicList: [String] {
    return shuffledMnemonicList
  }
  
  var getMnemonicListForVerification: [String] {
    return mnemonicListForVerification
  }
  
  func mnemonicVerificationViewDidLoad() {
    initShuffledMnemonicList()    
    view?.setNextButtonStatus(isEnabled: false)
  }
  
  func setGeneratedMnemonicList(generatedList: [String]) {
    generatedMnemonicList = generatedList
  }
  
  func shuffledWordWasPressed(with indexPath: IndexPath) {
    moveShuffledWordToListForVerification(by: indexPath)
    validateVerificationList()
  }
  
  func wordForVerificationWasPressed(with indexPath: IndexPath) {
    moveWordForVerificationToShuffledMnemonicList(by: indexPath)
    validateVerificationList()
  }
  
  func configureShuffled(_ cell: MnemonicCellView,
                         forRow row: Int) {
    cell.set(title: shuffledMnemonicList[row])
  }
  
  func configure(cellForVerification: MnemonicCellView,
                 forRow row: Int) {
    cellForVerification.set(title: mnemonicListForVerification[row])
  }
  
  func nextButtonWasPressed() {
    transitionToPinScreen()
  }
  
  func clearButtonWasPressed() {
    view?.deselectShuffledCollectionView()
    clearWordsForVerification()    
    validateVerificationList()
  }
  
  func helpButtonWasPressed() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let mnemonicVerificationViewController = view as! MnemonicVerificationViewController
    mnemonicVerificationViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
}
