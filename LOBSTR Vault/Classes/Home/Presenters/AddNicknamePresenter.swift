//

import Foundation
import UIKit
import stellarsdk

protocol AddNicknameView: AnyObject  {
  func closeScreen(isAfterSave: Bool, isNeedToShowInternetConnectionAlert: Bool)
  func setSaveButton(isEnabled: Bool)
  func setPlaceholder(for type: TextFieldType, isHidden: Bool)
  func setError(isHidden: Bool, error: String)
}

protocol AddNicknamePresenter {
  func viewDidLoad()
  func closeButtonWasPressed()
  func saveButtonWasPressed()
  func textFieldDidChange(text: String, type: TextFieldType)
  func showICloudSyncAdviceAlert()
  func showNoInternetConnectionAlert()
}

class AddNicknamePresenterImpl {
  private weak var view: AddNicknameView?
  private weak var delegate: AddNicknameDelegate?
    
  private var publicKey: String = ""
  private var nickname: String = ""
  
  private let federationService: FederationService
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  private var storageAccounts: [SignedAccount] = []
  
  private var isSaveButtonWasPressed = false
  
  init(view: AddNicknameView,
       delegate: AddNicknameDelegate?,
       federationService: FederationService = FederationService()) {
    self.view = view
    self.delegate = delegate
    self.federationService = federationService
  }
}

// MARK: - TransactionListPresenter

extension AddNicknamePresenterImpl: AddNicknamePresenter {
  
  func viewDidLoad() {
    storageAccounts = storage.retrieveAccounts() ?? []
    view?.setSaveButton(isEnabled: false)
  }
  
  func closeButtonWasPressed() {
    view?.closeScreen(isAfterSave: false, isNeedToShowInternetConnectionAlert: false)
  }
  
  func saveButtonWasPressed() {
    guard !isSaveButtonWasPressed else { return }
    isSaveButtonWasPressed = true
    if UserDefaultsHelper.isICloudSynchronizationEnabled {
      guard UIDevice.isConnectedToNetwork else {
        view?.closeScreen(isAfterSave: false, isNeedToShowInternetConnectionAlert: true)
        return
      }
      saveNickname()
    } else {
      saveNickname()
    }
  }
  
  func saveNickname() {
    guard !publicKey.isEmpty, publicKey.isStellarPublicAddress else {
      view?.setError(isHidden: false, error: L10n.textAddNicknamePublicKeyError)
      return
    }
    
    if !nickname.isEmpty {
      if let index = storageAccounts.firstIndex(where: { $0.address == publicKey }) {
        updateAccountWithNickname(index: index)
      } else {
        getFederation(for: publicKey)
      }
    }
  }
  
  func getFederation(for publicKey: String) {
    federationService.getFederation(for: publicKey) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let account):
        self.saveNewAccountWithNickname(publicKey: publicKey, federation: account.federation)
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
        self.saveNewAccountWithNickname(publicKey: publicKey, federation: nil)
      }
    }
  }
  
  func saveNewAccountWithNickname(publicKey: String, federation: String?) {
    let account = SignedAccount(address: publicKey, federation: federation, nickname: nickname, indicateAddress: AccountsStorageHelper.indicateAddress)
    storageAccounts.append(account)
    savedToICloud(account: account)
    storage.save(accounts: storageAccounts)
    NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
    NotificationCenter.default.post(name: .didNicknameSet, object: nil)
    delegate?.nicknameWasAdded()
    view?.closeScreen(isAfterSave: true, isNeedToShowInternetConnectionAlert: false)
  }
  
  func updateAccountWithNickname(index: Int) {
    storageAccounts[index].nickname = nickname
    savedToICloud(account: storageAccounts[index])
    storage.save(accounts: storageAccounts)
    NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
    NotificationCenter.default.post(name: .didNicknameSet, object: nil)
    delegate?.nicknameWasAdded()
    view?.closeScreen(isAfterSave: true, isNeedToShowInternetConnectionAlert: false)
  }
  
  func textFieldDidChange(text: String, type: TextFieldType) {
    view?.setPlaceholder(for: type, isHidden: !text.isEmpty)
    switch type {
    case .publicKey:
      publicKey = text
      view?.setError(isHidden: true, error: "")
    case .nickname:
      nickname = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    if !publicKey.isEmpty && !nickname.isEmpty {
      view?.setSaveButton(isEnabled: true)
    } else {
      view?.setSaveButton(isEnabled: false)
    }
  }
  
  func showICloudSyncAdviceAlert() {
    guard UIDevice.isConnectedToNetwork else { return }
    CloudKitNicknameHelper.checkIsICloudStatusAvaliable { isAvaliable in
      if isAvaliable {
        CloudKitNicknameHelper.isICloudDatabaseEmpty { result in
          if result, CloudKitNicknameHelper.isNeedToShowICloudSyncAdviceAlert {
            DispatchQueue.main.async {
              UserDefaultsHelper.isICloudSyncAdviceShown = true
              self.delegate?.showICloudSyncAdviceAlert()
            }
          }
        }
      }
    }
  }
  
  func showNoInternetConnectionAlert() {
    delegate?.showNoInternetConnectionAlert()
  }
  
  func savedToICloud(account: SignedAccount?) {
    CloudKitNicknameHelper.accountToSave = account
    if let accountToSave = CloudKitNicknameHelper.accountToSave {
      CloudKitNicknameHelper.saveToICloud(accountToSave)
    }
  }
}
