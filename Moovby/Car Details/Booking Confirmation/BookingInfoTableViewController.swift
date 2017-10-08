//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class BookingInfoTableViewController: UITableViewController {
  @IBOutlet var bookingInfoTableView: UITableView!
  @IBOutlet var pickupAddressTextView: UITextView!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var durationLabel: UILabel!
  @IBOutlet var startDateLabel: UILabel!
  @IBOutlet var startTimeLabel: UILabel!
  @IBOutlet var endDateLabel: UILabel!
  @IBOutlet var endTimeLabel: UILabel!
  var car: Car?
  var booking: Bookings?
  var address: String = ""
  var price: String = ""
  var hour: String = ""
  var week: String = ""
  var day: String = ""
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let latestbooking = BookingRepository().bookings().last else {
      return
    }
    bookingInfoTableView.tableFooterView = UIView()
    pickupAddressTextView.text = latestbooking.address
    priceLabel.text = "RM \(latestbooking.total)0"
    
    if latestbooking.weekDuration > 0 {
      week = "\(latestbooking.weekDuration) Week(s)"
    }
    if latestbooking.dayDuration > 0 {
      day = "\(latestbooking.dayDuration) Day(s)"
    }
    if latestbooking.hourDuration > 0 {
      hour = "\(latestbooking.hourDuration) Hour(s)"
    }
    
    durationLabel.text = "\(week) \(day) \(hour)"
    print("bitvs: \(latestbooking.starts)")
    startDateLabel.text = dateStringToString(date: latestbooking.starts)
    endDateLabel.text = dateStringToString(date: latestbooking.ends)
  }
  
  func configure(viewModel: InfoViewModle) {
    address = viewModel.address()
    price = viewModel.totalPrice()
  }
  
  //  for the textlabel
  func dateStringToString(date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
    let myDate = dateFormatter.date(from: date)
    
    dateFormatter.dateFormat = "dd MMM, HH:mm a"
    let somedateString = dateFormatter.string(from: myDate!)
    return somedateString
  }
}
