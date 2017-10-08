//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class VehicleDetail: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var model: String = ""
  dynamic var makerId: Int = 0
  dynamic var hourlyPrice: String = ""
  dynamic var dailyPrice: String = ""
  dynamic var weeklyPrice: String = ""
  dynamic var monthlyPrice: String = ""
  dynamic var vehicleType: String = ""
  dynamic var seatNumber: Int = 0
  dynamic var imageUrl: String = ""
  
  private dynamic var _defaultImage: Images?
  var defaultImage: ImagesProtocol? {
    get {
      return _defaultImage as! ImagesProtocol?
    } set {
      _defaultImage = newValue as? Images
    }
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map){
    self.init()
  }
  
  func mapping(map: Map){
    id <- map["id"]
    model <- map["model"]
    makerId <- map["maker_id"]
    hourlyPrice <- map["hourly_price"]
    dailyPrice <- map["daily_price"]
    weeklyPrice <- map["weekly_price"]
    monthlyPrice <- map["monthly_price"]
    vehicleType <- map["vehicle_type"]
    seatNumber <- map["seat_num"]
    imageUrl <- map["default_img.url"]
    _defaultImage <- map["default_img"]
  }
}
