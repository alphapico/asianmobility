//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Payment: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var bookingId: Int = 0
  dynamic var userId: Int = 0
  dynamic var method: String = ""
  dynamic var code: String = ""
  dynamic var url: String = ""
  dynamic var status: String = ""
  dynamic var createdAt: String = ""
  dynamic var updatedAt: String = ""
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    bookingId <- map["booking_id"]
    userId <- map["user_id"]
    method <- map["method"]
    code <- map["code"]
    url <- map["url"]
    status <- map["status"]
    createdAt <- map["created_at"]
    updatedAt <- map["updated_at"]
  }
}
