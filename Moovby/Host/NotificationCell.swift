//
//  NotificationCell.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 27/09/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import SwiftDate

class NotificationCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.numberOfLines = 0
      titleLabel.sizeToFit()
    }
  }
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func configure(notice: Notice) {
    let titleFontStyle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
    let bodyFontStyle = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
    let titleAttribute = [NSFontAttributeName: titleFontStyle]
    let bodyAttribute = [NSFontAttributeName: bodyFontStyle]
    let titleString = NSAttributedString(string:"\(notice.title!) ", attributes: titleAttribute)
    let bodyString = NSAttributedString(string: notice.body, attributes: bodyAttribute)

    let combinedAttributedText = NSMutableAttributedString()
    combinedAttributedText.append(titleString)
    combinedAttributedText.append(bodyString)

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.doesRelativeDateFormatting = true

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "h:mm a"

    let time = "\(dateFormatter.string(from: notice.createdAt)) at \(timeFormatter.string(from: notice.createdAt))"

    self.titleLabel.attributedText = combinedAttributedText
    self.dateLabel.text = time
  }
}
