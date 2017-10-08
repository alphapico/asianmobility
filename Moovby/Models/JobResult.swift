//
//  Copyright © 2017 Masrina. All rights reserved.
//

import RealmSwift
import ObjectMapper

class JobResult: Object, Mappable {
  dynamic var id: String = NSUUID().uuidString
  let message: String = ""
  let jobs = List<Jobs>()
  
  override class func primaryKey() -> String {
    return "id"
  }
  
  required convenience init?(map: Map){
    self.init()
  }
  
  func mapping(map: Map) {
    var jobs: [Jobs]?
    jobs <- map["jobs"]
    if let jobs = jobs {
      for jobs in jobs {
        self.jobs.append(jobs)
      }
    }
  }
}

