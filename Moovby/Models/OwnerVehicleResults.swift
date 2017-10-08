//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class OwnerVehicleResults: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  let message: String = ""
  let ownerVehicles = List<OwnerVehicle>()
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map){
    self.init()
  }
  
  func mapping(map: Map) {
    var ownerVehicles: [OwnerVehicle]?
    ownerVehicles <- map["user_vehicles"]
    if let ownerVehicles = ownerVehicles {
      for ownerVehicles in ownerVehicles {
        self.ownerVehicles.append(ownerVehicles)
      }
    }
  }
}
