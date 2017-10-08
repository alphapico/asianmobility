//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

class CarModelViewModel {
  let makers = MakerRepository().makers()
  
  func numberOfItems() -> Int {
    return makers.count
  }
  
  func itemAtIndex(indexPath: Int) -> String {
    return makers[indexPath].brand
  }
}
