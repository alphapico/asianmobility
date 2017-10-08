//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

protocol DateRangeProtocol {
  func selectedDuration(startDateToAPI: String, endDateToAPI: String, startDateLabel: String, endDateLabel: String)
}

class DurationViewController: UIViewController {
  
  fileprivate var singleDate: Date = Date()
  fileprivate var multipleDates: [Date] = []
//  let selector = WWCalendarTimeSelector.instantiate()
  
  @IBOutlet var startDateContainer: UIView!
  @IBOutlet var endDateContainer: UIView!
  @IBOutlet var startDateLabel: UILabel!
  @IBOutlet var endDateLabel: UILabel!
  @IBOutlet var setDateButton: UIButton!
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  var isStartDateSelected: Bool = false
  var delegate: DateRangeProtocol?
  let notificationName = Notification.Name.init("updateEndDate")
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startDateContainer.setupBorder()
    endDateContainer.setupBorder()
    setDateButton.layer.cornerRadius = 25
    
    if selectedStartDate != "" { // change string format
      startDateLabel.text = dateStringToString(date: selectedStartDate)//dateToString(date: selectedStartDate, dateFormat: "dd MMM, HH:mm a")
      endDateLabel.text = dateStringToString(date: selectedEndDate)//dateToString(date: selectedEndDate, dateFormat: "dd MMM, HH:mm a")
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateEndDate(notification:)), name: notificationName, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
  }
  
  static func instantiate() -> DurationViewController {
    return UIStoryboard(name: "SearchCriteria", bundle: nil).instantiateViewController(withIdentifier: "durationIdentifier") as! DurationViewController
  }
  
  func showCalendar(date: Date) {
    let selector = UIStoryboard(name: "WWCalendarTimeSelector", bundle: nil).instantiateInitialViewController() as! WWCalendarTimeSelector
    selector.delegate = self
    selector.optionCurrentDate = formatTime(date: date)
    selector.optionTopPanelTitle = "Booking Date & Time"
    selector.optionTopPanelBackgroundColor = UIColor.moovbyGreen
    selector.optionTintColor = UIColor.moovbyGreen
    selector.optionButtonFontColorDone = UIColor.moovbyGreen
    selector.optionTimeStep = .thirtyMinutes
    selector.optionCalendarFontColorPastDates = UIColor.lightGray
    
    /*
     Any other options are to be set before presenting selector!
     */
    present(selector, animated: true, completion: nil)
  }
  
  func formatTime(date: Date) -> Date {
    let calendar = Calendar.current
    let interval = 30
    let nextDiff = interval - calendar.component(.minute, from: date) % interval
    let nextDate = calendar.date(byAdding: .minute, value: nextDiff, to: date) ?? Date()
    
    if date.minute != 30 && date.minute != 0 {
      return nextDate
    }
    return date
  }
  
  @IBAction func selectStartDateButtonDidTapped(_ sender: Any) {
    isStartDateSelected = true
    if selectedStartDate.isEmpty {
      showCalendar(date: singleDate)
    } else {
      showCalendar(date: stringToDate(date: selectedStartDate))
    }
  }
  
  @IBAction func selectEndDateButtonDidTapped(_ sender: Any) {
    isStartDateSelected = false
    if selectedEndDate.isEmpty {
      showCalendar(date: setToNextNHours(date: stringToDate(date: selectedStartDate), value: 3))
    } else {
      showCalendar(date: stringToDate(date: selectedEndDate))
    }
  }
  
  func updateEndDate(notification: Notification) {
      let threeHoursFromStartDate = setToNextNHours(date: stringToDate(date: selectedStartDate), value: 3)
      let stringFormOfStartDate = dateToString(date: threeHoursFromStartDate, dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
      selectedEndDate = stringFormOfStartDate
      endDateLabel.text = dateToString(date: threeHoursFromStartDate, dateFormat: "dd MMM, HH:mm a")
  }
  
  func setToNextOneHour(date: Date) -> Date {
    let calendar = Calendar.current
    let newDate = calendar.date(byAdding: .hour, value: 1, to: date) ?? Date()
    
    return newDate
  }
  
  func setToNextNHours(date: Date, value: Int) -> Date {
    let calendar = Calendar.current
    let newDate = calendar.date(byAdding: .hour, value: value, to: date) ?? Date()
    
    return newDate
  }
  
  @IBAction func setDateButtonDidTapped(_ sender: Any) {
    guard let startDate = startDateLabel.text, let endDate = endDateLabel.text else { return }
    
    if startDate == "Start date" || endDate == "Return date" {
      let alertController = UIAlertController(title: "", message: "Please select Start and Return Date.", preferredStyle: UIAlertControllerStyle.alert)
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        (result : UIAlertAction) -> Void in
        print("OK")
      }
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
    else if (stringToDate(date: selectedStartDate) < setToNextOneHour(date: Date())) {
      displaySetTimeOneHourAlert()
      let setStartDate = setToNextOneHour(date: stringToDate(date: selectedStartDate))
      selectedStartDate = setStartDate.stringFromFormat("yyyy-MM-dd'T'HH:mm:ss")
      startDateLabel.text = dateToString(date: setStartDate, dateFormat: "dd MMM, HH:mm a")
    }
    else if (stringToDate(date: selectedEndDate) < setToNextNHours(date: stringToDate(date: selectedStartDate), value: 3)) {
      displaySetTimeAlert()
      let setEndDate = setToNextNHours(date: stringToDate(date: selectedStartDate), value: 3)
      selectedEndDate = setEndDate.stringFromFormat("yyyy-MM-dd'T'HH:mm:ss")
      endDateLabel.text = dateToString(date: setEndDate, dateFormat: "dd MMM, HH:mm a")
    }
    else {
      self.delegate?.selectedDuration(startDateToAPI: selectedStartDate, endDateToAPI: selectedEndDate, startDateLabel: startDate, endDateLabel: endDate)
      _ = navigationController?.popViewController(animated: true)
    }
  }
  
  func displaySetTimeAlert() {
    let alertController = UIAlertController(title: "", message: "Minimum booking is 3 hours", preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
      (result : UIAlertAction) -> Void in
      print("OK")
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func displaySetTimeOneHourAlert() {
    let alertController = UIAlertController(title: "", message: "Booking should start 1 hour from now.", preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
      (result : UIAlertAction) -> Void in
      print("OK")
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func doneButtonDidTapped(_ sender: Any) {
    guard let startDate = startDateLabel.text, let endDate = endDateLabel.text else { return }
    
    if startDate == "Select start date" || endDate == "Select end date" {
      let alertController = UIAlertController(title: "", message: "Please select Start and Return Date.", preferredStyle: UIAlertControllerStyle.alert)
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        (result : UIAlertAction) -> Void in
        print("OK")
      }
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    } else {
      self.delegate?.selectedDuration(startDateToAPI: selectedStartDate, endDateToAPI: selectedEndDate, startDateLabel: startDate, endDateLabel: endDate)
      _ = navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func backButtonDidTapped(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
  }
  
}

extension DurationViewController: WWCalendarTimeSelectorProtocol {
  func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
    print("Selected Date- \(date.stringFromFormat("yyyy-MM-dd'T'HH:mm:ss"))")
    
    if isStartDateSelected {
      selectedStartDate = date.stringFromFormat("yyyy-MM-dd'T'HH:mm:ss")//date.stringFromFormat("yyyy-MMM-y HH:mm:ss")
      startDateLabel.text = dateToString(date: date, dateFormat: "dd MMM, HH:mm a")
      
      if !selectedEndDate.isEmpty && (stringToDate(date: selectedEndDate) < stringToDate(date: selectedStartDate)) {
        NotificationCenter.default.post(name: notificationName, object: nil)
      }
      
      isStartDateSelected = false
    } else {
      selectedEndDate = date.stringFromFormat("yyyy-MM-dd'T'HH:mm:ss")
      endDateLabel.text = dateToString(date: date, dateFormat: "dd MMM, HH:mm a")
    }
    //dateLabel.text = date.stringFromFormat("d' 'MMMM' 'yyyy', 'h':'mma")
  }
  
  func WWCalendarTimeSelectorCancel(_ selector: WWCalendarTimeSelector, date: Date) {
    
  }
  
  func WWCalendarTimeSelectorShouldSelectDate(_ selector: WWCalendarTimeSelector, date: Date) -> Bool {
    let currentDate = Date()
    
    if date < currentDate {
      return false
    } else {
      return true
    }
  }
  
  func dateToString(date: Date, dateFormat: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat//"M/d/yy, H:mm"
    return dateFormatter.string(from: date)
  }
  
  //  for the textlabel
  func dateStringToString(date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let myDate = dateFormatter.date(from: date)
    
    dateFormatter.dateFormat = "dd MMM, HH:mm a"
    let somedateString = dateFormatter.string(from: myDate!)
    return somedateString
  }
  
  func stringToDate(date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let myDate = dateFormatter.date(from: date) ?? Date()
    
    return myDate
  }
}
