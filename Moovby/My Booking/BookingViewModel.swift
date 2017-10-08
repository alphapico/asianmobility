//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

class BookingViewModel {
  var bookings: [Bookings] = []
  
  func loadBookings() {
    let bookings = BookingRepository().currentBooking()
    self.bookings = bookings
  }
  
  func loadPastBooking() {
    let bookings = BookingRepository().pastBooking()
    self.bookings = bookings
  }
  
  func numberOfItems() -> Int {
    return bookings.count
  }
  
  func itemAtIndex(index: Int) -> Bookings? {
    return bookings[index]
  }
}
