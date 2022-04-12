//

import Foundation
import UIKit
import stellarsdk

protocol TransactionImportView: class {
  func closeScreen()
  func setError(isHidden: Bool, error: String)
  func setClipboard(text: String)
  func textWasPasted(text: String)
  func setSubmitButton(isEnabled: Bool)
  func setPlaceholder(isHidden: Bool)
}

protocol TransactionImportPresenter {
  func viewDidLoad()
  func closeButtonWasPressed()
  func submitButtonWasPressed(with text: String)
  func pasteFromClipboardButtonWasPressed()
  func textViewDidChange(text: String) 
}

class TransactionImportPresenterImpl {
  private weak var view: TransactionImportView?
  private var delegate: TransactionImportDelegate?
  
  var clipboardString: String = ""
  
  init(view: TransactionImportView, delegate: TransactionImportDelegate?) {
    self.view = view
    self.delegate = delegate
  }
}

// MARK: - TransactionListPresenter

extension TransactionImportPresenterImpl: TransactionImportPresenter {
  
  func viewDidLoad() {
    tryToGetTextFromClipboard()
    self.view?.setSubmitButton(isEnabled: false)
  }
  
  func closeButtonWasPressed() {
    self.view?.closeScreen()
  }
  
  func submitButtonWasPressed(with text: String) {
    let xdr: String = text.filter { !$0.isWhitespace }
    guard let _ = try? TransactionEnvelopeXDR(xdr: xdr) else {
      self.view?.setError(isHidden: false, error: L10n.textInvalidXdrError)
      return
    }
    
    self.view?.closeScreen()
    self.delegate?.submitTransaction(with: xdr)
  }
  
  func pasteFromClipboardButtonWasPressed() {
    self.view?.textWasPasted(text: clipboardString)
    self.view?.setSubmitButton(isEnabled: true)
    self.view?.setError(isHidden: true, error: "")
    self.view?.setPlaceholder(isHidden: true)
  }
    
  func textViewDidChange(text: String) {
    self.view?.setPlaceholder(isHidden: !text.isEmpty)
    tryToGetTextFromClipboard()
    let string = text.filter { !$0.isWhitespace }
    self.view?.setSubmitButton(isEnabled: !string.isEmpty)
    self.view?.setError(isHidden: true, error: "")
  }
}

// MARK: - Private

extension TransactionImportPresenterImpl {
  private func tryToGetTextFromClipboard() {
    clipboardString = UIPasteboard.general.string ?? ""
    let xdr: String = clipboardString.filter { !$0.isWhitespace }
    if let _ = try? TransactionEnvelopeXDR(xdr: xdr) {
      self.view?.setClipboard(text: xdr)
    }
  }
}
