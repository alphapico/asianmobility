//
//  Copyright © 2017 Moovby. All rights reserved.
//

import RealmSwift
import ObjectMapper

class BookingResult: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  let message: String = ""
  let bookings = List<Bookings>()
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map){
    self.init()
  }
  
  func mapping(map: Map) {
    var bookings: [Bookings]?
    bookings <- map["bookings"]
    if let bookings = bookings {
      for bookings in bookings {
        self.bookings.append(bookings)
      }
    }
  }
}
