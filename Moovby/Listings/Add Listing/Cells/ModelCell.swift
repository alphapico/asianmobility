//
//  ModelCell.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 06/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Kingfisher

class ModelCell: UITableViewCell {

  @IBOutlet weak var modelImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func configure(model: Model) {
    titleLabel.text = model.model.localizedCapitalized
    modelImageView.kf.setImage(with: model.imageUrl, options: [.transition(.fade(0.4))])

  }
}
