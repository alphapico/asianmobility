//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

protocol UserProtocol {
  var id: Int { get set }
  var email: String { get set }
  var isAdmin: Bool { get set }
  var isSuperAdmin: Bool { get set }
  var facebookUID: String { get set }
  var googleUID: String { get set }
}
