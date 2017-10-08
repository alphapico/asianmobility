//
//  CustomHeaderCell.swift
//  Moovby
//
//  Created by Masrina on 27/02/2017.
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit

class CustomHeaderCell: UITableViewCell {
  @IBOutlet weak var profileImageView: UIImageView! {
    didSet {
      profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
      profileImageView.clipsToBounds = true
      profileImageView.image = UIImage(named: "mapInfoViewPlaceholder")
    }
  }
  @IBOutlet var userNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}

extension CustomHeaderCell: Reusable {}
