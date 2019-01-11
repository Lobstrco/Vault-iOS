import Foundation
import LocalAuthentication

protocol AuthСontext {
  func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
  func evaluatePolicy(_ policy: LAPolicy,
                      localizedReason: String,
                      reply: @escaping (Bool, Error?) -> Void)
}

extension LAContext: AuthСontext { }
