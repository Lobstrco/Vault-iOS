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

// MARK: - MnemonicRecoveryStoryboardCreation

protocol MnemonicRecoveryStoryboardCreation: StoryboardCreation {}

extension MnemonicRecoveryStoryboardCreation {
  static var storyboardType: Storyboards { return Storyboards.mnemonicRecovery }
}

// MARK: - MnemonicGenerationStoryboardCreation

protocol MnemonicGenerationStoryboardCreation: StoryboardCreation {}

extension MnemonicGenerationStoryboardCreation {
  static var storyboardType: Storyboards { return Storyboards.mnemonicGeneration }
}

// MARK: - MnemonicVerificationStoryboardCreation

protocol MnemonicVerificationStoryboardCreation: StoryboardCreation {}

extension MnemonicVerificationStoryboardCreation {
  static var storyboardType: Storyboards { return Storyboards.mnemonicGeneration }
}

// MARK: - MnemonicMenuViewControllerStoryboardCreation

protocol MnemonicMenuViewControllerStoryboardCreation: StoryboardCreation {}

extension MnemonicMenuViewControllerStoryboardCreation {
  static var storyboardType: Storyboards { return Storyboards.mnemonicMenu }
}
