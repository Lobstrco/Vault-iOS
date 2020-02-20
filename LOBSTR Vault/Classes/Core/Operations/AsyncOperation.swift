import Foundation

class AsyncOperation: Operation {
  
  var outputError: Error?
  
  enum State: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
      return "is" + rawValue.capitalized
    }
  }
  
  var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }
  
  func finished(error: Error?) {
    state = .finished
    
    if let error = error {
      self.outputError = error
    }
  }
}

// MARK: - Operation override

extension AsyncOperation {
  
  override var isReady: Bool {
    return super.isReady && state == .ready
  }
  
  override var isExecuting: Bool {
    return state == .executing
  }
  
  override var isFinished: Bool {
    return state == .finished
  }
  
  override var isAsynchronous: Bool {
    return true
  }
  
  override func start() {    
    if outputError != nil {
      finished(error: outputError)
      return
    }
    
    if isCancelled {
      state = .finished
      return
    }
    main()
    state = .executing
  }  
  
  override func cancel() {
    state = .finished
  }
  
  
  
}
