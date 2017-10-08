//
//  CustomTextField.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 07/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

  let padding: CGFloat = 8

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureUI()
  }

  required override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.width + padding * 2, height: bounds.height)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.width + padding * 2, height: bounds.height)
  }

  fileprivate func configureUI() {
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 1.0
    self.layer.cornerRadius = 4.0
  }
}
