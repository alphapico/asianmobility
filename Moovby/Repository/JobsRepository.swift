//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift

class JobRepository {
  func jobs() -> [Jobs] {
    return RealmRepository().objects(type: Jobs.self)
  }
  
  func jobsByVehicleId(vehicleId: Int) -> Jobs? {
    return RealmRepository().objectWithPredicate(type: Jobs.self, predicate: NSPredicate(format: "vehicleId = \(vehicleId)")).last
  }
  
  func currentJob() -> [Jobs] {
    let predicate = NSPredicate(format: "status != 'draft' && status != 'completed' && status != 'canceled' && status != 'rejected'")
    let realm = try! Realm()
    let jobs = realm.objects(Jobs.self).filter(predicate).sorted(byKeyPath: "updatedAt", ascending: false)
    return jobs.results(ofType: Jobs.self) as [Jobs]
  }
  
  func pastJob() -> [Jobs] {
    let predicate = NSPredicate(format: "status != 'draft' && status != 'awaiting payment' && status != 'requested' && status != 'confirmed'")
    let realm = try! Realm()
    let jobs = realm.objects(Jobs.self).filter(predicate).sorted(byKeyPath: "updatedAt", ascending: false)
    return jobs.results(ofType: Jobs.self) as [Jobs]
  }
}
