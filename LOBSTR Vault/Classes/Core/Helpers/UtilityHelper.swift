import Foundation
import UIKit

struct UtilityHelper {
  
  static func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)
      
      if let output = filter.outputImage?.transformed(by: transform) {
        
        let colorParameters = [
          "inputColor0": CIColor(color: Asset.Colors.main.color),
          "inputColor1": CIColor(color: UIColor.clear)
        ]
        let colored = output.applyingFilter("CIFalseColor", parameters: colorParameters)

        
        return UIImage(ciImage: colored)
      }
    }
    
    return nil
  }
}
