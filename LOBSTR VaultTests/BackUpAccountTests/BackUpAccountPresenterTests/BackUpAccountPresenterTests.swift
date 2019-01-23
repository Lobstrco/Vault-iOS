@testable import LOBSTR_Vault
import XCTest

class BackUpAccountPresenterTests: XCTestCase {
  var sut: BackUpAccountPresenter!
  var backUpAccountViewSpy: BackAccountViewSpy!
  
  override func setUp() {
    backUpAccountViewSpy = BackAccountViewSpy()
    sut = BackUpAccountPresenterImpl(view: backUpAccountViewSpy,
                                     navigationController: UINavigationController())
  }
  
  override func tearDown() {
    sut = nil
  }
  
  func testBackUpAccountPresenterShouldSetTitleToViewAfterViewDidLoad() {
    sut.backUpAccountViewDidLoad()
    
    let expectedTitle = "Back up account"
    let resultTitle = backUpAccountViewSpy.title
    XCTAssertEqual(resultTitle, expectedTitle)
  }
}

extension BackUpAccountPresenterTests {
  class BackAccountViewSpy: BackUpAccountView {
    var title: String = ""
    
    func setTitle(_ title: String) {
      self.title = title
    }
  }
}
