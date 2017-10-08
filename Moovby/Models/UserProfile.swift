//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class UserProfile: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var firstName: String = ""
  dynamic var lastName: String = ""
  dynamic var phoneNumber: String = ""
  dynamic var isCarOwner: Bool = false
  dynamic var isRenter: Bool = false
  dynamic var icImage: String = ""
  dynamic var drivingLicenseImage: String = ""
  dynamic var isVerified: Bool = false
  dynamic var isRequested: Bool = false
  dynamic var role: Int = 0
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    firstName <- map["first_name"]
    lastName <- map["last_name"]
    isVerified <- map["renter_verified"]
    phoneNumber <- map["phone"]
    icImage <- map["ic.url"]
    drivingLicenseImage <- map["driving_license.url"]
    role <- map["role"]
  }
}
