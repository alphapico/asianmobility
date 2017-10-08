//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

class JobViewModel {
  var jobs: [Jobs] = []
  
  func loadJobs() {
    let jobs = JobRepository().currentJob()
    self.jobs = jobs
  }
  
  func loadPastJob() {
    let jobs = JobRepository().pastJob()
    self.jobs = jobs
  }
  
  func numberOfItems() -> Int {
    return jobs.count
  }
  
  func itemAtIndex(index: Int) -> Jobs? {
    return jobs[index]
  }
}
