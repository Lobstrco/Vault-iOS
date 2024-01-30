//
import Foundation
import Presentr

struct PresentationHelper {
  static func createPresentationType(parentView: UIViewController, tabBarHeight: CGFloat, cellsCount: Int, cellHeight: CGFloat) -> PresentationType {
    var finalHeight: CGFloat = 0.0

    let statusBarHeight: CGFloat = 20.0
    let navigationBarHeight: CGFloat = 44.0
    let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
    let screenHeight: CGFloat = UIScreen.main.bounds.height -
      statusBarHeight -
      navigationBarHeight -
      bottomSafeArea

    let headerHeight: CGFloat = 62.0
    let cellsCountLimit = MnemonicHelper.additionalAccountsCountLimit + 1
    let bottomHeight: CGFloat = cellsCount == cellsCountLimit ? 14.0 : 90.0

    let calculatedHeight = CGFloat(cellsCount) * cellHeight + headerHeight + bottomHeight + bottomSafeArea

    if calculatedHeight > screenHeight {
      finalHeight = screenHeight
    } else {
      finalHeight = calculatedHeight
    }

    let width = ModalSize.full
    let height = ModalSize.custom(size: Float(finalHeight))

    let center = ModalCenterPosition.custom(centerPoint:
      CGPoint(x: parentView.view.bounds.width  / 2,
              y: parentView.view.bounds.height - finalHeight
                + finalHeight / 2 + tabBarHeight))

    let customType = PresentationType.custom(width: width,
                                             height: height,
                                             center: center)
    return customType
  }
  
  static func createPresentationMaxScreenHeightType() -> PresentationType {
    let statusBarHeight: CGFloat = 20.0
    let navigationBarHeight: CGFloat = 44.0
    let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
    let screenHeight: CGFloat = UIScreen.main.bounds.height -
      statusBarHeight -
      navigationBarHeight -
      bottomSafeArea
    
    let width = ModalSize.full
    let height = ModalSize.custom(size: Float(screenHeight))

    let center = ModalCenterPosition.custom(centerPoint:
      CGPoint(x: UIScreen.main.bounds.width / 2,
              y: UIScreen.main.bounds.height - screenHeight
                + screenHeight / 2))

    let customType = PresentationType.custom(width: width,
                                             height: height,
                                             center: center)
    return customType
  }
}
