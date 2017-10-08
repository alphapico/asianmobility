//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class User: Object, Mappable {
  dynamic var id: Int = 0
  dynamic var email: String = ""
  dynamic var isAdmin: Bool = false
  dynamic var isSuperAdmin: Bool = false
  dynamic var facebookUID: String = ""
  dynamic var googleUID: String = ""
  
  private dynamic var _userProfile: UserProfile?
  var userProfile: UserProfileProtocol? {
    get {
      return _userProfile as! UserProfileProtocol?
    } set {
      _userProfile = newValue as? UserProfile
    }
  }
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    email <- map["email"]
    isAdmin <- map["is_admin"]
    isSuperAdmin <- map["is_super_admin"]
    facebookUID <- map["fb_uid"]
    googleUID <- map["google_uid"]
    _userProfile <- map["profile"]
  }
}
