//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class UserProfileResult: Object, Mappable {
  dynamic var id: String = UUID().uuidString
  private dynamic var _user: User?
  var user: UserProtocol? {
    get {
      return _user as! UserProtocol?
    } set {
      _user = newValue as? User
    }
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    _user <- map["user"]
  }
}
