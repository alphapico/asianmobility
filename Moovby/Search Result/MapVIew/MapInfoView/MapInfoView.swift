//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class MapInfoView: UIView {
  @IBOutlet var carImageView: UIImageView!
  @IBOutlet var carTitlelabel: UILabel!
  @IBOutlet var carModelLabel: UILabel!
  @IBOutlet var carPriceRateLabel: UILabel!
  @IBOutlet var carAddressLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func configure(viewModel: CarCellViewModel) {
    carImageView.kf.setImage(with: URL(string: viewModel.imageUrl()), placeholder: UIImage(named: "MapInfoViewPlaceholder"), options: [.transition(.fade(0.8))])
    carTitlelabel.text = viewModel.title()
    carModelLabel.text = viewModel.type()
    carPriceRateLabel.text = viewModel.price()
    carAddressLabel.text = viewModel.address()
  }

}
