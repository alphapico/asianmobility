//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

class CarListViewModel {
  var cars: [Car] = []
  
  func loadCars() {
    let cars = VehicleRepository().vehicles()
    self.cars  = cars
  }
  
  func numberOfItems() -> Int {
    return cars.count
  }
  
  func itemAtIndex(index: Int) -> Car? {
    return cars[index]
  }
}
