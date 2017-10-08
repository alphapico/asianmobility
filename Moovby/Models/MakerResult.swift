//
//  Copyright © 2017 Moovby. All rights reserved.
//

import ObjectMapper
import RealmSwift

class MakerResult: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  let makers = List<Maker>()
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    var makers: [Maker]?
    makers <- map["makers"]
    if let makers = makers {
      for makers in makers {
        self.makers.append(makers)
      }
    }
  }
}
