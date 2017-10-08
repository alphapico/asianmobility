//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class PaymentResult: Object, Mappable {
  private dynamic var id = NSUUID().uuidString
  private dynamic var _payment: Payment?
  var payment: PaymentProtocol? {
    get {
      return _payment as! PaymentProtocol?
    } set {
      _payment = newValue as? Payment
    }
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    _payment <- map["payment"]
  }
  
}
