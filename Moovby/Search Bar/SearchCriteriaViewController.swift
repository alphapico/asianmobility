//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class SearchCriteriaViewController: UIViewController, CLLocationManagerDelegate, DateRangeProtocol {
  @IBOutlet var backgroundView: UIView!
  @IBOutlet var currentLocationViewContainer: UIView!
  @IBOutlet var dateViewContainer: UIView!
  @IBOutlet var searchButton: UIButton!
  @IBOutlet var locationLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  var startDateDescription: String?
  var endDateDescription: String?
  var delegate: SearchProtocol?
  var placesClient: GMSPlacesClient!
  var latitude: CLLocationDegrees?
  var longitude: CLLocationDegrees?
  var locationName: String?
  var vehicleType: String?
  var vehicleBrand: String?
  let locationManager = CLLocationManager()
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  var isUber: Bool = false
  
  fileprivate var singleDate: Date = Date()
  fileprivate var multipleDates: [Date] = []
  let selector = WWCalendarTimeSelector.instantiate()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpView()
    placesClient = GMSPlacesClient.shared()
    if locationName == "Search Moovby" || locationName == "Current Location" {
      locationLabel.text = "Current Location"
    } else {
      locationLabel.text = locationName
    }
    
    if !selectedStartDate.isEmpty {
      startDateDescription = dateStringToString(date: selectedStartDate)//dateToString(date: selectedStartDate, dateFormat: "dd MMM, HH:mm a")
      endDateDescription = dateStringToString(date: selectedEndDate)//dateToString(date: selectedEndDate, dateFormat: "dd MMM, HH:mm a")
      dateLabel.text = "\(startDateDescription!) - \(endDateDescription!)"
    }
    
  }
  
  func setUpView() {
    currentLocationViewContainer.layer.borderColor = UIColor.moovbyGreen.cgColor
    currentLocationViewContainer.layer.borderWidth = 1
    currentLocationViewContainer.layer.cornerRadius = 3
    
    dateViewContainer.layer.borderColor = UIColor.moovbyGreen.cgColor
    dateViewContainer.layer.borderWidth = 1
    dateViewContainer.layer.cornerRadius = 3
    
    searchButton.layer.cornerRadius = searchButton.frame.height/2
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func searchButtonDidTapped(_ sender: Any) {
    guard let place = locationLabel.text, let latitude = latitude, let longitude = longitude else { return }
    
    let selectedType = self.vehicleType == nil ? "" : self.vehicleType?.lowercased()
    let selectedBrand = self.vehicleBrand == nil ? "" : self.vehicleBrand?.lowercased()
    let beginDate = self.selectedStartDate//?.stringFromFormat("yyyy-MMM-dd'T'HH:mm:ss")
    let selectEndDate = self.selectedEndDate//?.stringFromFormat("yyyy-MMM-dd'T'HH:mm:ss")
    
    self.delegate?.updateSearchResult(place: place, latitude: latitude, longitude: longitude, vehicleType: selectedType!, vehicleBrand: selectedBrand!, startDate: beginDate, endDate: selectEndDate, isUber: isUber)
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func searchLocationDidTapped(_ sender: Any) {
    guard let latitude = latitude, let longitude = longitude else { return }
    let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
    let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
    let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    let config = GMSPlacePickerConfig(viewport: viewport)
    let placePicker = GMSPlacePicker(config: config)
    
    placePicker.pickPlace(callback: {(place, error) -> Void in
      if let error = error {
        print("Pick Place error: \(error.localizedDescription)")
        return
      }
      
      if let place = place {
        self.locationLabel.text = place.name
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
      } else {
        self.locationLabel.text = "Current Location"
      }
    })
  }
  
  func updateUserLocation() {
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else {
      return
    }
    latitude = location.coordinate.latitude
    longitude = location.coordinate.longitude
    locationManager.stopUpdatingLocation()
  }
  
  @IBAction func searchDateDidTapped(_ sender: Any) {
//    showCalendar()
    print("searchDate")
  }
  
  @IBAction func getCurrentLocationDidTapped(_ sender: Any) {
    self.locationLabel.text = "Current Location"
    updateUserLocation()
  }
  
  @IBAction func clearAllButtonDidTapped(_ sender: Any) {
    locationLabel.text = "Current Location"
    dateLabel.text = "How many days"
    vehicleType = ""
    vehicleBrand = ""
    selectedStartDate = ""
    selectedEndDate = ""
    updateUserLocation()
//    self.delegate?.updateDateSelected(isSelected: false)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "dateDurationSegue" {
      let viewController = (segue.destination as! DurationViewController)
      viewController.selectedStartDate = selectedStartDate
      viewController.selectedEndDate = selectedEndDate
      viewController.delegate = self
    }
  }
  
  func selectedDuration(startDateToAPI: String, endDateToAPI: String, startDateLabel: String, endDateLabel: String) {
    selectedStartDate = startDateToAPI
    selectedEndDate = endDateToAPI
    dateLabel.text = "\(startDateLabel) - \(endDateLabel)"
    print("\(startDateDescription) - \(endDateDescription)")
  }
  
//  func selectedDuration(startDate: String, endDate: String) {
//    selectedStartDate = startDate//.stringFromFormat("dd-MMM-yyyy'T'HH:mm:ss")
//    selectedEndDate = endDate//.stringFromFormat("dd-MMM-yyyy'T'HH:mm:ss")
//    startDateDescription = dateStringToString(date: startDate)//dateToString(date: startDate, dateFormat: "dd MMM, HH:mm a")
//    endDateDescription = dateStringToString(date: endDate)//dateToString(date: endDate, dateFormat: "dd MMM, HH:mm a")
//    dateLabel.text = "\(startDateDescription) - \(endDateDescription)"
//    print("\(startDateDescription) - \(endDateDescription)")
//  }
}

extension SearchCriteriaViewController {
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
}
