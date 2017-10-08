//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

class CarDetailsViewModel {
  let car: Car
  let vehicleDetail: VehicleDetail

  init(car: Car) {
    self.car = car
    vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId)!
  }

  func carId() -> Int {
    return car.id
  }
  
  func carImage() -> String {
    return vehicleDetail.imageUrl
  }
  
  func title() -> String {
    guard let maker = MakerRepository().makerById(makerId: vehicleDetail.makerId) else {
        return ""
    }
    
    let cartitle = "\(car.year) \(maker.brand) \(vehicleDetail.model)"
    return cartitle
  }
  
  func hourlyRate() -> String {
    return vehicleDetail.hourlyPrice
  }
}
