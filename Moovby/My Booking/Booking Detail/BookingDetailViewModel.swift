//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import CoreLocation

class BookingDetailViewModel {
  var booking: Bookings?

  func loadBooking(booking: Bookings) {
    self.booking = booking
  }
  
  func bookingId() -> Int {
    return (booking?.id)!
  }
  
  func latitude() -> CLLocationDegrees {
    return booking!.latitude
  }
  
  func longitude() -> CLLocationDegrees {
    return booking!.longitude
  }
  
  func carTitle() -> String {
    guard let car = VehicleRepository().carById(carId: (booking?.vehicleId)!),
      let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId),
      let maker = MakerRepository().makerById(makerId: vehicleDetail.makerId) else {
        return ""
    }
    let cartitle = "\(maker.brand) \(vehicleDetail.model)"
    return cartitle
  }
  
  func startDate() -> String {
    return formatStringOfDate(date: booking!.starts, format: "MMM d, h:mm a")
  }
  
  func endDate() -> String {
    return formatStringOfDate(date: booking!.ends, format: "MMM d, h:mm a")
  }
  
  func formatStringOfDate(date: String, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.locale = Locale.init(identifier: "en_GB")
    let dateObj = dateFormatter.date(from: date)
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: dateObj!)
  }
  
  func duration() -> String {
    var week = ""
    var day = ""
    var hour = ""
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
  
  func reservationEnd() -> String {
    return formatStringOfDate(date: booking!.ends, format: "h:mm a")
  }
  
  func bookingStatus() -> String {
    if booking!.status == "canceled" {
      return "Cancelled"
    } else {
      return booking!.status.capitalized
    }
  }
  
  func vehicleId() -> Int {
    return (booking?.vehicleId)!
  }
  
  func plateNumber() -> String {
    guard let car = VehicleRepository().carById(carId: (booking?.vehicleId)!) else {
        return ""
    }
    return car.plateNumber
  }
  
  func totalAmount() -> String {
    return String(format: "RM %.2f", Double(booking!.total)!)
  }
}
