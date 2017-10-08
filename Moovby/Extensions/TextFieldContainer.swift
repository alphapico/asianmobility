//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

extension UIView {
  func setupBorder() {
    self.layer.cornerRadius = 5
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.white.cgColor
  }
  
  func setupBorderGreen() {
    self.layer.borderColor = UIColor.moovbyGreen.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 3
  }
}
