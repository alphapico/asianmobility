//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
  let checkedImage = UIImage(named: "checked")
  let uncheckedImage = UIImage(named: "unchecked")
  
  var isChecked: Bool = false {
    didSet {
      if isChecked == true {
//        self.setImage(checkedImage, for: .normal)
      } else {
//        self.setImage(uncheckedImage, for: .normal)
      }
    }
  }
  
  override func awakeFromNib() {
    self.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
    self.isChecked = false
  }
  
  func buttonClicked(_ sender: UIButton) {
    if sender == self {
      isChecked = !isChecked
    }
  }
}
