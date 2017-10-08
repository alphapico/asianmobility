//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

protocol UserProfileProtocol {
  var id: Int { get set }
  var firstName: String { get set }
  var lastName: String { get set }
  var phoneNumber: String { get set }
  var isCarOwner: Bool { get set }
  var isRenter: Bool { get set }
  var icImage: String { get set }
  var drivingLicenseImage: String { get set }
  var isVerified: Bool { get set }
  var isRequested: Bool { get set }
}
