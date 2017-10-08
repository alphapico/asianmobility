//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import RealmSwift

class PaymentRepository {
  func paymentFirstObject() -> Payment? {
    return RealmRepository().objects(type: Payment.self).first
  }
  
  func paymentWithBookingId(bookingId: Int) -> Payment? {
    return RealmRepository().objectWithPredicate(type: Payment.self, predicate: NSPredicate(format: "bookingId = \(bookingId))")).first
  }
}
