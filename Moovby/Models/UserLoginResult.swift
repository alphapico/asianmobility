//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class UserLoginResult: Object, Mappable {
  dynamic var authorizationToken: String = ""
  private dynamic var _user: User?
  var user: UserProtocol? {
    get {
      return _user as! UserProtocol?
    } set {
      _user = newValue as? User
    }
  }
  
  override class func primaryKey() -> String {
    return "authorizationToken"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    authorizationToken <- map["auth_token"]
    _user <- map["user"]
  }
}
