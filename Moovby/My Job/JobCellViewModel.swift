//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import CoreLocation

class JobCellViewModel {
  let jobs: Jobs
  
  init(jobs: Jobs) {
    self.jobs = jobs
  }
  
  func carTitle() -> String {
    guard let car = VehicleRepository().carById(carId: jobs.vehicleId),
      let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId),
      let maker = MakerRepository().makerById(makerId: vehicleDetail.makerId) else {
        return ""
    }
    let cartitle = "\(maker.brand) \(vehicleDetail.model)"
    return cartitle
  }
  
  func price() -> String {
    let totalPrice = jobs.code.isEmpty ? jobs.total : jobs.totalAfterPromo
    return String(format: "RM %.2f", Double(totalPrice)!)
  }
  
  func status() -> String {
    if jobs.status == "canceled" {
      return "Cancelled"
    } else {
      return jobs.status.capitalized
    }
  }
  
  func latitude() -> CLLocationDegrees {
    return jobs.latitude
  }
  
  func longitude() -> CLLocationDegrees {
    return jobs.longitude
  }
  
  func isPaid() -> String {
    if jobs.isPaid {
      return "PAID"
    } else {
      return "UNPAID"
    }
  }
  
  func startDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.locale = Locale.init(identifier: "en_GB")
    let dateObj = dateFormatter.date(from: jobs.starts)
    dateFormatter.dateFormat = "dd/MM/yyyy, h:mm a"
    return dateFormatter.string(from: dateObj!)
  }
  
  func promoCode() -> String {
    return jobs.code
  }
}
