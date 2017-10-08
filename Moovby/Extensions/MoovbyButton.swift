//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
  func disable() {
    self.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
    self.layer.borderColor = UIColor.clear.cgColor
    self.isUserInteractionEnabled = false
  }
  
  func enable() {
    self.backgroundColor = UIColor.white
    self.layer.borderColor = UIColor.white.cgColor
    self.isUserInteractionEnabled = true
  }
}
