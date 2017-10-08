//
//  Copyright © 2017 Moovby. All rights reserved.
//

import ObjectMapper
import RealmSwift
import CoreLocation

class Bookings: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var userId: Int = 0
  dynamic var vehicleId: Int = 0
  dynamic var status: String = ""
  dynamic var starts: String = ""
  dynamic var ends: String = ""
  dynamic var isPaid: Bool = false
  dynamic var total: String = ""
  dynamic var token: String = ""
  dynamic var address: String = ""
  dynamic var latitude: CLLocationDegrees = 0.0
  dynamic var longitude: CLLocationDegrees = 0.0
  dynamic var weekDuration: Int = 0
  dynamic var dayDuration: Int = 0
  dynamic var hourDuration: Int = 0
  dynamic var minuteDuration: String = ""
  dynamic var createdAt: String = ""
  dynamic var updatedAt: String = ""
  dynamic var code: String = ""
  dynamic var totalAfterPromo: String = ""
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    userId <- map["user_id"]
    vehicleId <- map["vehicle_id"]
    status <- map["status"]
    starts <- map["starts"]
    ends <- map["ends"]
    isPaid <- map["paid"]
    total <- map["total"]
    token <- map["token"]
    address <- map["address"]
    latitude <- map["latitude"]
    longitude <- map["longitude"]
    weekDuration <- map["wk"]
    dayDuration <- map["dy"]
    hourDuration <- map["hr"]
    minuteDuration <- map["mn"]
    createdAt <- map["created_at"]
    updatedAt <- map["updated_at"]
    code <- map["code"]
    totalAfterPromo <- map["total_after_promo"]
  }
}
