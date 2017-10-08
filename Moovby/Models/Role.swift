//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation

enum RoleType: Int {
  case Renter = 1
  case Owner = 2
}

class Role: NSObject {
  static let sharedInstance = Role()
  private override init() {}
  
  var userRole = RoleType.Renter.rawValue
}
