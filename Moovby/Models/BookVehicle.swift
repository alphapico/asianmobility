//
//  Copyright © 2017 Masrina. All rights reserved.
//

import RealmSwift
import ObjectMapper

class BookVehicle: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  let message: String = ""
  private dynamic var _booking: Bookings?
  var booking: BookingProtocol? {
    get {
      return _booking as! BookingProtocol?
    } set {
      _booking = newValue as? Bookings
    }
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map){
    self.init()
  }
  
  func mapping(map: Map) {
    _booking <- map["bookings"]
  }
}

