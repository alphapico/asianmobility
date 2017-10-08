//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import CoreLocation

class BookingConfirmationViewModel {
  var booking: Bookings?
  var week: String = ""
  var day: String = ""
  var hour: String = ""
  
  func loadBookings(vehicleId: Int) {
    guard let booking = BookingRepository().bookingByVehicleId(vehicleId: vehicleId) else { return }
    self.booking = booking
  }
  
  func bookingId() -> Int {
    guard let booking = booking else { return 0 }
    return booking.id
  }
  
  func duration() -> String {
    guard let booking = booking else { return "-" }
    if booking.weekDuration > 0 {
      week = "\(booking.weekDuration) Week(s)"
    }
    if booking.dayDuration > 0 {
      day = "\(booking.dayDuration) Day(s)"
    }
    if booking.hourDuration > 0 {
      hour = "\(booking.hourDuration) Hour(s)"
    }
    
    return "\(week) \(day) \(hour)"
  }
  
  func latitude() -> CLLocationDegrees {
    return booking!.latitude
  }
  
  func longitude() -> CLLocationDegrees {
    return booking!.longitude
  }
  
  func totalPrice() -> String {
    guard let booking = booking else {
      return "-"
    }
    return String(format: "RM %.2f", Double(booking.total)!)
  }
  
  func totalAfterPromo() -> String {
    guard let booking = booking else {
      return ""
    }
    return String(format: "RM %.2f", Double(booking.totalAfterPromo)!)
  }
}
