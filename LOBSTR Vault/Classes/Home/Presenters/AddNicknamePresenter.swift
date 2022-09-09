//

import Foundation
import UIKit
import stellarsdk

protocol AddNicknameView: AnyObject {
  func closeScreen()
  func setSaveButton(isEnabled: Bool)
  func setPlaceholder(for type: TextFieldType, isHidden: Bool)
  func setError(isHidden: Bool, error: String)
}

protocol AddNicknamePresenter {
  func viewDidLoad()
  func closeButtonWasPressed()
  func saveButtonWasPressed()
  func textFieldDidChange(text: String, type: TextFieldType)
}

class AddNicknamePresenterImpl {
  private weak var view: AddNicknameView?
  private weak var delegate: AddNicknameDelegate?
    
  private var publicKey: String = ""
  private var nickname: String = ""
  
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  private var storageAccounts: [SignedAccount] = []
  
  init(view: AddNicknameView, delegate: AddNicknameDelegate?) {
    self.view = view
    self.delegate = delegate
  }
}

// MARK: - TransactionListPresenter

extension AddNicknamePresenterImpl: AddNicknamePresenter {
  
  func viewDidLoad() {
    storageAccounts = storage.retrieveAccounts() ?? []
    view?.setSaveButton(isEnabled: false)
  }
  
  func closeButtonWasPressed() {
    view?.closeScreen()
  }
  
  func saveButtonWasPressed() {
    guard !publicKey.isEmpty, publicKey.isStellarPublicAddress else {
      view?.setError(isHidden: false, error: L10n.textAddNicknamePublicKeyError)
      return
    }
    
    if !nickname.isEmpty {
      if let index = storageAccounts.firstIndex(where: { $0.address == publicKey }) {
        storageAccounts[index].nickname = nickname
      } else {
        let account = SignedAccount(address: publicKey, federation: nil, nickname: nickname)
        storageAccounts.append(account)
      }
      storage.save(accounts: storageAccounts)
      NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
      NotificationCenter.default.post(name: .didNicknameSet, object: nil)
      delegate?.nicknameWasAdded()
      view?.closeScreen()
    }
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
}
