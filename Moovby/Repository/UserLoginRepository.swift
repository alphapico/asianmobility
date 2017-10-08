//
//  Copyright © 2017 Moovby. All rights reserved.
//

import RealmSwift

class UserLoginRepository {
  func userLoginResult() -> [UserLoginResult] {
    return RealmRepository().objects(type: UserLoginResult.self)
  }
  
  func users() -> [User] {
    return RealmRepository().objects(type: User.self)
  }
}
