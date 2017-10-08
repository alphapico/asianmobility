//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation

class PaymentViewModel {
  let repo = PaymentRepository()
  
  func url() -> String {
    return (repo.paymentFirstObject()?.url)!
  }
}
