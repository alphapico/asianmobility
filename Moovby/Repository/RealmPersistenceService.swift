//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift

class RealmPersistenceService {
  func setUpDatabase() {
    if let realmFile = Realm.Configuration.defaultConfiguration.fileURL {
      print("Realm File URL: \(realmFile)")
    }
  }
}
