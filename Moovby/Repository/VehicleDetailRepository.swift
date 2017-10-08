//
//  Copyright © 2017 Moovby. All rights reserved.
//

import RealmSwift

class VehicleDetailRepository {
  func vehicleDetailById(vehicleDetailId: Int) -> VehicleDetail? {
    return RealmRepository().objectWithPredicate(type: VehicleDetail.self, predicate: NSPredicate(format: "id = \(vehicleDetailId)")).first
  }
}
