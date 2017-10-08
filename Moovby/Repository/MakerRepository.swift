//
//  Copyright © 2017 Moovby. All rights reserved.
//

import RealmSwift

class MakerRepository {
  func makers() -> [Maker] {
    return RealmRepository().objects(type: Maker.self)
  }
  
  func makerById(makerId: Int) -> Maker? {
    return RealmRepository().objectWithPredicate(type: Maker.self, predicate: NSPredicate(format: "id = \(makerId)")).first
  }
}
