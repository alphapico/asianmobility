//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class MoovbyImage: Object, Mappable, MoovbyImageProtocol {
  dynamic var url: String = ""
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    url <- map["url"]
  }
}
