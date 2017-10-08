//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Kingfisher
import CoreLocation

class CarTableViewCell: UITableViewCell {

  @IBOutlet var carImageView: UIImageView!
  @IBOutlet var carTitleLabel: UILabel!
  @IBOutlet var carTypeLabel: UILabel!
  @IBOutlet var carPriceLabel: UILabel!
  @IBOutlet var distanceLabel: UILabel!
  var userLatitude: CLLocationDegrees?
  var userLongitude: CLLocationDegrees?

  override func awakeFromNib() {
    super.awakeFromNib()
  }



  func configure(viewModel: CarCellViewModel) {
    carImageView.kf.setImage(with: URL(string: viewModel.imageUrl()), placeholder: UIImage(named: "MapInfoViewPlaceholder"), options: [.transition(.fade(0.8))])
    carTitleLabel.text = viewModel.title()
    carTypeLabel.text = viewModel.type()
    carPriceLabel.text = viewModel.price()
    if (userLatitude != nil) {
      distanceLabel.text = viewModel.distance(userLatitude: userLatitude!, userLongitude: userLongitude!)
    } else {
      distanceLabel.text = viewModel.distance(userLatitude: 0.0, userLongitude: 0.0)
    }
  }
}
