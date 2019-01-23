import Foundation
import UIKit

protocol MnemonicVerificationView: class {
  func displayShuffledMnemonicList()
  func updateCollectionViewForVerification()
  func updateShuffledCollectionView(by indexPath: IndexPath, color: UIColor)
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
  func configureShuffled(_ cell: MnemonicCollectionViewCell, forRow row: Int)
  func configure(cellForVerification: MnemonicCollectionViewCell, forRow row: Int)
  
  func nextButtonAction()
}

class MnemonicVerificationPresenterImpl {
  fileprivate weak var view: MnemonicVerificationView?
  fileprivate var generatedMnemonicList: [String] = []
  fileprivate var shuffledMnemonicList: [String] = []
  fileprivate var mnemonicListForVerification: [String] = []
  
  fileprivate weak var crashlyticsService: CrashlyticsService?
  
  // MARK: - Init
  
  init(view: MnemonicVerificationView, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
  }
  
  // MARK: - Public Methods
  
  func initShuffledMnemonicList() {
    guard !generatedMnemonicList.isEmpty else { return }
    
    shuffledMnemonicList = generatedMnemonicList.shuffled()
    view?.displayShuffledMnemonicList()
  }
  
  func getIndexPathFromShuffledMnemonicList(by index: Int) -> IndexPath {
    let indexInShuffledList =
      shuffledMnemonicList.firstIndex(of: mnemonicListForVerification[index])
    return IndexPath(item: indexInShuffledList!, section: 0)
  }
  
  func moveShuffledWordToListForVerification(by indexPath: IndexPath) {
    mnemonicListForVerification.append(shuffledMnemonicList[indexPath.item])
    view?.updateShuffledCollectionView(by: indexPath, color: UIColor.gray)
    view?.updateCollectionViewForVerification()
  }
  
  func moveWordForVerificationToShuffledMnemonicList(by indexPath: IndexPath) {
    view?.updateShuffledCollectionView(by: getIndexPathFromShuffledMnemonicList(by: indexPath.item),
                                       color: UIColor.white)
    mnemonicListForVerification.remove(at: indexPath.item)
    view?.updateCollectionViewForVerification()
  }
}

// MARK: - MnemonicVerificationPresenter

extension MnemonicVerificationPresenterImpl: MnemonicVerificationPresenter {
  
  var countOfMnemonicListForVerification: Int {
    return mnemonicListForVerification.count
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
  }
  
  func setGeneratedMnemonicList(generatedList: [String]) {
    generatedMnemonicList = generatedList
  }
  
  func shuffledWordWasPressed(with indexPath: IndexPath) {
    moveShuffledWordToListForVerification(by: indexPath)
  }
  
  func wordForVerificationWasPressed(with indexPath: IndexPath) {
    moveWordForVerificationToShuffledMnemonicList(by: indexPath)
  }
  
  func configureShuffled(_ cell: MnemonicCollectionViewCell,
                         forRow row: Int) {
    cell.display(title: shuffledMnemonicList[row])
  }
  
  func configure(cellForVerification: MnemonicCollectionViewCell,
                 forRow row: Int) {
    cellForVerification.display(title: mnemonicListForVerification[row])
  }
  
  func nextButtonAction() {
    transitionToPinScreen()
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
