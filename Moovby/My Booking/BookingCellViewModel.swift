//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import CoreLocation

class BookingCellViewModel {
  let booking: Bookings
  
  init(booking: Bookings) {
    self.booking = booking
  }
  
  func carTitle() -> String {
    guard let car = VehicleRepository().carById(carId: booking.vehicleId),
      let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId),
      let maker = MakerRepository().makerById(makerId: vehicleDetail.makerId) else {
      return ""
    }
    let cartitle = "\(maker.brand) \(vehicleDetail.model)"
    return cartitle
  }
  
  func price() -> String {
    let totalPrice = booking.code.isEmpty ? booking.total : booking.totalAfterPromo
    return String(format: "RM %.2f", Double(totalPrice)!)
  }
  
  func status() -> String {
    if booking.status == "canceled" {
      return "Cancelled"
    } else {
      return booking.status.capitalized
    }
  }
  
  func latitude() -> CLLocationDegrees {
    return booking.latitude
  }
  
  func longitude() -> CLLocationDegrees {
    return booking.longitude
  }
  
  func isPaid() -> String {
    if booking.isPaid {
      return "PAID"
    } else {
      return "UNPAID"
    }
  }
  
  func startDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.locale = Locale.init(identifier: "en_GB")
    let dateObj = dateFormatter.date(from: booking.starts)
    dateFormatter.dateFormat = "MMM d, h:mm a"
    return dateFormatter.string(from: dateObj!)
  }
  
  func promoCode() -> String {
    return booking.code
  }
}
