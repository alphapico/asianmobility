//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

class CarTypeViewModel {
  var carTypes: [String] = ["None", "4x4", "COMPACT", "MPV", "SEDAN", "VAN"]
  
  func numberOfItems() -> Int {
    return carTypes.count
  }
  
  func itemAtIndex(index: Int) -> String {
    return carTypes[index]
  }
}
