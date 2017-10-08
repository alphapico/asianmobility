//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift

class UserProfileRepository {
  func profile() -> [UserProfile] {
    return RealmRepository().objects(type: UserProfile.self)
  }
}
