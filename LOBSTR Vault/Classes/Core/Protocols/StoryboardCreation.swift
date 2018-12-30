import UIKit

protocol StoryboardCreation where Self: UIViewController {
  static var storyboardType: Storyboards { get }
  static func createFromStoryboard() -> Self?
}

extension StoryboardCreation {
  static func createFromStoryboard() -> Self? {
    let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? Self
  }
}
