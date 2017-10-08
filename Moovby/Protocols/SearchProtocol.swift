//
//  Copyright © 2017 Moovby. All rights reserved.
//

import CoreLocation

protocol SearchProtocol {
  func updateSearchResult(place: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, vehicleType: String, vehicleBrand: String, startDate: String, endDate: String, isUber: Bool)
  func updateDateSelected(isSelected: Bool)
}
