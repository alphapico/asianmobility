//
//  Copyright © 2017 Moovby. All rights reserved.
//

import CoreLocation

protocol BookingProtocol {
  var id: Int { get set }
  var userId: Int { get set }
  var vehicleId: Int { get set }
  var status: String { get set }
  var starts: String { get set }
  var ends: String { get set }
  var isPaid: Bool { get set }
  var total: String { get set }
  var token: String { get set }
  var address: String { get set }
  var latitude: CLLocationDegrees { get set }
  var longitude: CLLocationDegrees { get set }
  var weekDuration: Int { get set }
  var dayDuration: Int { get set }
  var hourDuration: Int { get set }
  var minuteDuration: Int { get set }
  var totalAfterPromo: String { get set }
}
