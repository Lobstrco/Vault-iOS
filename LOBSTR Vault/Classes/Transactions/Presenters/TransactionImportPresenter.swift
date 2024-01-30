//

import Foundation
import stellarsdk
import UIKit

protocol TransactionImportView: AnyObject {
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
  private weak var delegate: TransactionImportDelegate?

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
    if UIPasteboard.general.hasStrings {
      // The permission dialog that prompts users when pasting text
      // from the clipboard may close immediately,
      // leaving users with no time to perform the pasting action.
      // A potential workaround is to make two consecutive calls to UIPasteboard.general.string.
      // https://developer.apple.com/forums/thread/724160
      if #available(iOS 16, *) {
        getTextFromClipboard()
      }
      getTextFromClipboard()
    }
  }

  private func getTextFromClipboard() {
    clipboardString = UIPasteboard.general.string ?? ""
    let xdr: String = clipboardString.filter { !$0.isWhitespace }
    if let _ = try? TransactionEnvelopeXDR(xdr: xdr) {
      self.view?.setClipboard(text: xdr)
    }
  }
}
