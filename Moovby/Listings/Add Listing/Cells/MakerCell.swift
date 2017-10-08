//
//  MakerCell.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 05/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class MakerCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func configure(maker: Maker) {
    self.titleLabel.text = maker.brand
  }
}
