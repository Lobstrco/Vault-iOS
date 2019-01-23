import XCTest
@testable import LOBSTR_Vault

class MnemonicGenerationPresenterTest: XCTestCase {

  let mnemonicGenerationViewSpy = MnemonicGenerationViewSpy()
  var mnemonicGenerationPresenter: MnemonicGenerationPresenterImpl!
  
  override func setUp() {
    super.setUp()
    mnemonicGenerationPresenter = MnemonicGenerationPresenterImpl(view: mnemonicGenerationViewSpy)
  }
}
