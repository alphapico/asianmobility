//
//  MakerHeadCell.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 05/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class MakerHeadCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func configure(_ title: String) {
    self.titleLabel.text = title
  }
}
