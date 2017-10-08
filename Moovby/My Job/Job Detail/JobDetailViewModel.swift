//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import CoreLocation

class JobDetailViewModel {
  var job: Jobs?
  
  func loadJob(job: Jobs) {
    self.job = job
  }
  
  func jobId() -> Int {
    return (job?.id)!
  }
  
  func latitude() -> CLLocationDegrees {
    return job!.latitude
  }
  
  func longitude() -> CLLocationDegrees {
    return job!.longitude
  }
  
  func carTitle() -> String {
    guard let car = VehicleRepository().carById(carId: (job?.vehicleId)!),
      let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId),
      let maker = MakerRepository().makerById(makerId: vehicleDetail.makerId) else {
        return ""
    }
    let cartitle = "\(maker.brand) \(vehicleDetail.model)"
    return cartitle
  }
  
  func startDate() -> String {
    return formatStringOfDate(date: job!.starts, format: "MMM d, h:mm a")
  }
  
  func endDate() -> String {
    return formatStringOfDate(date: job!.ends, format: "MMM d, h:mm a")
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
    guard let job = job else { return "-" }
    if job.weekDuration > 0 {
      week = "\(job.weekDuration) Week(s)"
    }
    if job.dayDuration > 0 {
      day = "\(job.dayDuration) Day(s)"
    }
    if job.hourDuration > 0 {
      hour = "\(job.hourDuration) Hour(s)"
    }
    
    return "\(week) \(day) \(hour)"
  }
  
  func reservationEnd() -> String {
    return formatStringOfDate(date: job!.ends, format: "h:mm a")
  }
  
  func jobStatus() -> String {
    if job!.status == "canceled" {
      return "Cancelled"
    } else {
      return job!.status.capitalized
    }
  }
  
  func vehicleId() -> Int {
    return (job?.vehicleId)!
  }
  
  func plateNumber() -> String {
    guard let car = VehicleRepository().carById(carId: (job?.vehicleId)!) else {
      return ""
    }
    return car.plateNumber
  }
  
  func totalAmount() -> String {
    return String(format: "RM %.2f", Double(job!.total)!)
  }
}
