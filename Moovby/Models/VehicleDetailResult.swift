//
//  Copyright © 2017 Moovby. All rights reserved.
//

import ObjectMapper
import RealmSwift

class VehicleDetailResult: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  let vehicleDetail = List<VehicleDetail>()
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    var vehicleDetail: [VehicleDetail]?
    vehicleDetail <- map["vehicle_detail"]
    if let vehicleDetail = vehicleDetail {
      for vehicleDetail in vehicleDetail {
        self.vehicleDetail.append(vehicleDetail)
      }
    }
  }
}
