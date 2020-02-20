import UIKit

protocol CustomPopoverDelegate: class {
  func closePopover()
}

class CustomPopoverViewController: UIViewController {
  
  lazy var backdropView: UIView = {
    let bdView = UIView(frame: self.view.bounds)
    bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    return bdView
  }()
  
  var mainTabBarController: UITabBarController?
  
  var menuView: UIView
  var height: CGFloat
  var isPresenting = false
  var withBackground: Bool
  
  var scrollView: UIScrollView?
  
  init(height: CGFloat, view: UIView, withBackground: Bool = true) {
    
    self.height = height
    self.menuView = view
    self.withBackground = withBackground
    
    super.init(nibName: nil, bundle: nil)
    
    modalPresentationStyle = .custom
    transitioningDelegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .clear
    if (withBackground) {
      view.addSubview(backdropView)
    }
    view.addSubview(menuView)
    
    menuView.translatesAutoresizingMaskIntoConstraints = false
    menuView.heightAnchor.constraint(equalToConstant: height).isActive = true
    menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    scrollView = menuView.subviews.first as? UIScrollView
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    
    guard let scrollView = scrollView else {
      return
    }    
    
    let keyboardScreenEndFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let keyboardFrame = view.convert(keyboardScreenEndFrame, from: view.window)

    var contentInset: UIEdgeInsets = scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height
    scrollView.contentInset = contentInset
  }
  
  @objc func keyboardWillHide(notification:NSNotification){
    scrollView?.contentInset = UIEdgeInsets.zero
  }
}

extension CustomPopoverViewController: CustomPopoverDelegate {
  
  func closePopover() {
    NotificationCenter.default.removeObserver(self)
    dismiss(animated: true, completion: nil)
  }
}

extension CustomPopoverViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 1
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
    guard let toVC = toViewController else { return }
    isPresenting = !isPresenting
    
    if isPresenting == true {
      containerView.addSubview(toVC.view)
      
      menuView.frame.origin.y += height
      backdropView.alpha = 0
      
      UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
        self.menuView.frame.origin.y -= self.height
        self.backdropView.alpha = 1
      }, completion: { (finished) in
        transitionContext.completeTransition(true)
      })
    } else {
      UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
        self.menuView.frame.origin.y += self.height
        self.backdropView.alpha = 0
      }, completion: { (finished) in
        transitionContext.completeTransition(true)
      })
    }
  }
}
