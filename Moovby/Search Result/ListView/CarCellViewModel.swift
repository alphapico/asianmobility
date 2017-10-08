//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import CoreLocation

class CarCellViewModel {
  let car: Car
  
  init(car: Car) {
    self.car = car
  }
  
  func imageUrl() -> String {
    guard let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId) else {
      return ""
    }
    return vehicleDetail.imageUrl
  }

  func title() -> String {
    guard let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId),
      let maker = MakerRepository().makerById(makerId: vehicleDetail.makerId) else {
        return ""
    }
    
    let cartitle = "\(car.year) \(maker.brand) \(vehicleDetail.model)"
    return cartitle
  }
  
  func type() -> String {
    guard let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId) else {
      return ""
    }
    return vehicleDetail.vehicleType.capitalized
  }
  
  func price() -> String {
    guard let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId) else {
      return ""
    }
    let price = vehicleDetail.hourlyPrice
    return "RM \(price)0/hour"
  }
  
  func address() -> String {
    return car.address
  }
  
  func distance(userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees) -> String {
    let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
    let carLocation = CLLocation(latitude: CLLocationDegrees(car.latitude), longitude: CLLocationDegrees(car.longitude))
    let distance = userLocation.distance(from: carLocation) / 1000
    
    return String(format: "%.01f KM", distance)
  }
}
