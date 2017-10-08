//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift

class RealmRepository<T: Object> {
  let realm = try! Realm()
  
  func refresh() {
    realm.refresh()
  }
  
  func objects(type: T.Type) -> [T] {
    return realm.objects(type).results(ofType: T.self) as [T]
  }

  func objectWithPredicate(type: T.Type, predicate: NSPredicate) -> [T] {
    return realm.objects(type).filter(predicate).results(ofType: T.self) as [T]
  }
  
  func deleteObject(object: Object) {
    realm.delete(object)
  }
  
}

extension Results {
  func results<T>(ofType: T.Type) -> [T] {
    var array = [T]()
    for i in 0 ..< count {
      if let result = self[i] as? T {
        array.append(result)
      }
    }
    
    return array
  }
}

