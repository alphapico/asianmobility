//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class NavigationDrawerCell: UITableViewCell {
  @IBOutlet var titleLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}

extension NavigationDrawerCell: Reusable {}
