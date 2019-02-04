import UIKit

class Snackbar: UIView {
  
  enum SnackType {
    case copy
    case info
  }
  
  fileprivate static let snackbarDefaultFrame: CGRect = CGRect(x: 0, y: 0, width: 320, height: 44)
  
  fileprivate var contentView: UIView?
  fileprivate var parentView: UIView?
  
  fileprivate var snackType: SnackType!
  
  // MARK: - Init
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init(parentView: UIView, snackType: SnackType) {
    super.init(frame: Snackbar.snackbarDefaultFrame)
    self.parentView = parentView
    self.snackType = snackType
    configure()
  }
  
}

extension Snackbar {
  
  func show() {
    
    let dismissTimer = Timer.init(timeInterval: (TimeInterval)(4),
                                  target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
    RunLoop.main.add(dismissTimer, forMode: .common)
    
    addSubview(contentView!)
    
    contentView?.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
    contentView?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    contentView?.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
    contentView?.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    
    if let superView = parentView { //UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow {
      superView.addSubview(self)
      
      centerXAnchor.constraint(equalTo: superview!.centerXAnchor).isActive = true
      bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -12).isActive = true
      
      widthAnchor.constraint(equalToConstant: 127).isActive = true
      heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
  }
  
  @objc public func dismiss() {
    DispatchQueue.main.async {
      () -> Void in
      self.removeFromSuperview()
    }
  }
  
  func configure() {
    for subView in subviews {
      subView.removeFromSuperview()
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    
    contentView = UIView()
    contentView?.translatesAutoresizingMaskIntoConstraints = false
    contentView?.frame = Snackbar.snackbarDefaultFrame
    contentView?.layer.cornerRadius = 4
    
    let title = UILabel()
    title.textColor = Asset.Colors.white.color
    
    contentView?.addSubview(title)
    
    title.translatesAutoresizingMaskIntoConstraints = false
    title.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    title.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
    
    switch snackType {
    case .copy?:
      contentView?.backgroundColor = Asset.Colors.confirm.color
      title.text = "Copied"
    default:
      break
    }
  }
}
