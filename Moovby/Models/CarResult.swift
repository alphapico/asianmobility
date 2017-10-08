//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class CarResult: Object, Mappable {
  dynamic var id: String = UUID().uuidString
  private dynamic var _car: Car?
  var car: VehicleProtocol? {
    get {
      return _car as! VehicleProtocol?
    } set {
      _car = newValue as! Car
    }
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    _car <- map["vehicle"]
  }
}
