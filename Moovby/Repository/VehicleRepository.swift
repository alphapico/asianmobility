//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift

class VehicleRepository {
  func vehicles() -> [Car] {
    return RealmRepository().objects(type: Car.self)
  }
  
  func carById(carId: Int) -> Car? {
    return RealmRepository().objectWithPredicate(type: Car.self, predicate: NSPredicate(format: "id = \(carId)")).first
  }
}
