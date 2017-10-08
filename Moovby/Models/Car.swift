//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Car: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var vehicleDetailId: Int = 0
  dynamic var userId: Int = 0
  dynamic var isInsuranceValid: Bool = false
  dynamic var year: Int = 0
  dynamic var transmission: String = ""
  dynamic var color: String = ""
  dynamic var plateNumber: String = ""
  dynamic var isVerified: Bool = false
  dynamic var isAvailable: Bool = false
  dynamic var createdAt: Date?
  dynamic var updatedAt: Date?
  dynamic var carDescription: String = ""
//  dynamic var roadTax: String = ""
//  dynamic var insuranceCoverNote: String = ""
  dynamic var address: String = ""
  dynamic var latitude: Float = 0.0
  dynamic var longitude: Float = 0.0
  dynamic var viewCount: Int = 0
  dynamic var distance: Float = 0.0
  dynamic var bearing: String = ""
  // TODO: Add reviews variable
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  // Mappable
  func mapping(map: Map) {
    id <- map["id"]
    vehicleDetailId <- map["vehicle_detail_id"]
    userId <- map["user_id"]
    isInsuranceValid <- map["is_insurance_valid"]
    year <- map["year"]
    transmission <- map["transmission"]
    color <- map["color"]
    plateNumber <- map["plate_num"]
    isVerified <- map["is_verified"]
    isAvailable <- map["is_available"]
    createdAt <- map["created_at"]
    updatedAt <- map["updated_at"]
    carDescription <- map["description"]
    address <- map["address"]
    latitude <- map["latitude"]
    longitude <- map["longitude"]
    viewCount <- map["view_count"]
    distance <- map["distance"]
    bearing <- map["bearing"]
  }
}
