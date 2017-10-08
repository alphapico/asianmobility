//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation

class GeneralSelectionViewModel {
  var items: [String] = []
  
  init(items: [String]) {
    self.items = items
  }
  
  func numberOfItems() -> Int {
    return items.count
  }
  
  func itemAtIndex(index: Int) -> String {
    return items[index]
  }
}
