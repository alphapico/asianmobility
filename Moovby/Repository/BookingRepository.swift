//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift

class BookingRepository {
  func bookings() -> [Bookings] {
    return RealmRepository().objects(type: Bookings.self)
  }
  
  func bookingByVehicleId(vehicleId: Int) -> Bookings? {
    return RealmRepository().objectWithPredicate(type: Bookings.self, predicate: NSPredicate(format: "vehicleId = \(vehicleId)")).last
  }
  
  func currentBooking() -> [Bookings] {
    let predicate = NSPredicate(format: "status != 'draft' && status != 'completed' && status != 'canceled' && status != 'rejected'")
    let realm = try! Realm()
    let bookings = realm.objects(Bookings.self).filter(predicate).sorted(byKeyPath: "updatedAt", ascending: false)
    return bookings.results(ofType: Bookings.self) as [Bookings]
  }
  
  func pastBooking() -> [Bookings] {
    let predicate = NSPredicate(format: "status != 'draft' && status != 'awaiting payment' && status != 'requested' && status != 'confirmed'")
    let realm = try! Realm()
    let bookings = realm.objects(Bookings.self).filter(predicate).sorted(byKeyPath: "updatedAt", ascending: false)
    return bookings.results(ofType: Bookings.self) as [Bookings]
  }
}
