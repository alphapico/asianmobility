//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

protocol VehicleProtocol {
  var vehicleDetailId: Int { get set }
  var userID: Int { get set }
  var isInsuranceValid: Bool { get set }
  var year: Int { get set }
  var transmission: String { get set }
  var color: String { get set }
  var plateNumbers: String { get set }
  var isVerified: Bool { get set }
  var isAvailable: Bool { get set }
  var createdAt: Date { get set }
  var address: String { get set }
  var latitude: Float { get set }
  var longitude: Float { get set }
  var viewCount: Int { get set }
  var distance: Float { get set }
  var bearing: String { get set }
}
