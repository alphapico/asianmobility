//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import Kingfisher

class ListingTableViewCell: UITableViewCell {

  @IBOutlet weak var carImageView: UIImageView!
  @IBOutlet weak var modelLabel: UILabel!
  @IBOutlet weak var plateNumberLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  func configureCellFor(car: Car, details: VehicleDetail) {
    print("CAR: ", car)
    print("DETAIL: ", details)
    carImageView.kf.setImage(with: URL(string: details.imageUrl), options: [.transition(.fade(0.4))])
    modelLabel.text = details.model
    plateNumberLabel.text = car.plateNumber.uppercased()
    if car.isAvailable {
      statusLabel.text = "Available"
    } else {
      statusLabel.text = "Not Available"
    }
  }
}
