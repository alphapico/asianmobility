//
//  Copyright © 2017 Moovby. All rights reserved.
//

import RealmSwift
import ObjectMapper

class SearchResult: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  dynamic var message: String = ""
  let vehicles = List<Car>()
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    message <- map["message"]
    var vehicles: [Car]?
    vehicles <- map["vehicles"]
    if let vehicles = vehicles {
      for vehicles in vehicles {
        self.vehicles.append(vehicles)
      }
    }
  }
}
