//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Maker: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var origin: String = ""
  dynamic var brand: String = ""
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    origin <- map["origin"]
    brand <- map["brand"]
  }
}
