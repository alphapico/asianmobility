//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import RealmSwift

enum VehicleDetailSelectionType: String {
  case model
  case year
  case transmission
  case color
}

class AddVehicleDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var vehicleModelContainer: UIView!
  @IBOutlet weak var vehicleYearContainer: UIView!
  @IBOutlet weak var transmissionContainer: UIView!
  @IBOutlet weak var colorContainer: UIView!
  @IBOutlet weak var plateNumberContainer: UIView!
  @IBOutlet weak var locationContainer: UIView!
  @IBOutlet weak var vehicleDescriptionTextView: UITextView!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var modelLabel: UILabel!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var transmissionLabel: UILabel!
  @IBOutlet weak var colorLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var carPlateNumberLabel: UITextField!
  var placesClient: GMSPlacesClient!
  var latitude: CLLocationDegrees?
  var longitude: CLLocationDegrees?
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    placesClient = GMSPlacesClient.shared()
    
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  // MARK: - Private func
  private func setupView() {
    vehicleModelContainer.setupBorderGreen()
    vehicleYearContainer.setupBorderGreen()
    transmissionContainer.setupBorderGreen()
    colorContainer.setupBorderGreen()
    plateNumberContainer.setupBorderGreen()
    locationContainer.setupBorderGreen()
    vehicleDescriptionTextView.setupBorderGreen()
    nextButton.layer.cornerRadius = nextButton.frame.height/2
    
    vehicleDescriptionTextView.delegate = self
  }
  
  func viewTapped(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  // MARK: - UITextViewDelegate
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.vehicleDescriptionTextView = textView
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    self.vehicleDescriptionTextView = nil
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func keyboardWillShow(notification:NSNotification) {
    var userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    
    var contentInset:UIEdgeInsets = scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height
    scrollView.contentInset = contentInset
  }
  
  func keyboardWillHide(notification:NSNotification) {
    let contentInset:UIEdgeInsets = UIEdgeInsetsMake(65, 0, 0, 0)
    scrollView.contentInset = contentInset
  }
  
  // MARK: - Button action
  @IBAction func selectVehicleButtonTapped(_ sender: Any) {
    let generalSelectionViewController = GeneralSelectionViewController.instantiate()
    generalSelectionViewController.delegate = self
    generalSelectionViewController.selectionItems = ["Mitsubishi - Attrage", "Mitsubishi - Lancer", "Mitsubishi - Triton",
                                                     "Hyundai - Starex",
                                                     "Ford - Range",
                                                     "Suzuki -Swift",
                                                     "Proton - Suprima S", "Proton - Persona", "Proton - Saga", "Proton - Iriz", "Proton - Inspira", "Proton - Exora", "Proton - Preve",
                                                     "Nissan - Navara", "Nissan - Sentra", "Nissan - Urvan", "Nissan - Sylphy", "Nissan - Livina", "Nissan - Almera",
                                                     "Volkswagen - Golf 1.4", "Volkswagen - Polo",
                                                     "Honda - Insight", "Honda - Civic", "Honda - Accord", "Honda - City", "Honda - Odyssey", "Honda - CRV",
                                                     "Toyota - Estima", "Toyota - Avanza", "Toyota - Wish", "Toyota - Alphard", "Toyota - Hiace", "Toyota - Hilux", "Toyota - Innova", "Toyota - Camry", "Toyota - Vios", "Toyota - Prius", "Toyota - Vellfire",
                                                     "Perodua - Kenari", "Perodua - Axia", "Perodua - Myvi", "Perodua - Bezza", "Perodua - Alza", "Perodua - Viva"]
    generalSelectionViewController.type = VehicleDetailSelectionType.model.rawValue
    self.navigationController?.pushViewController(generalSelectionViewController, animated: true)
  }
  
  @IBAction func selectVehicleYearButtonTapped(_ sender: Any) {
    let generalSelectionViewController = GeneralSelectionViewController.instantiate()
    generalSelectionViewController.delegate = self
    generalSelectionViewController.selectionItems = ["2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017"]
    generalSelectionViewController.type = VehicleDetailSelectionType.year.rawValue
    self.navigationController?.pushViewController(generalSelectionViewController, animated: true)
  }
  
  @IBAction func selectTransmissionButtonTapped(_ sender: Any) {
    let generalSelectionViewController = GeneralSelectionViewController.instantiate()
    generalSelectionViewController.delegate = self
    generalSelectionViewController.selectionItems = ["Auto", "Manual"]
    generalSelectionViewController.type = VehicleDetailSelectionType.transmission.rawValue
    self.navigationController?.pushViewController(generalSelectionViewController, animated: true)
  }
  
  @IBAction func selectColorButtonTapped(_ sender: Any) {
    let generalSelectionViewController = GeneralSelectionViewController.instantiate()
    generalSelectionViewController.delegate = self
    generalSelectionViewController.selectionItems = ["Black", "White", "Yellow", "Pink", "Green", "Blue", "Red", "Others"]
    generalSelectionViewController.type = VehicleDetailSelectionType.color.rawValue
    self.navigationController?.pushViewController(generalSelectionViewController, animated: true)
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
        self.locationLabel.text = "Vehicle Location"
      }
    })
  }
  
//  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//    if identifier == "documentsImages" {
//      guard let carModel = modelLabel.text, let carYear = yearLabel.text, let transmission = transmissionLabel.text, let color = colorLabel.text, let plateNumber = carPlateNumberLabel.text, let carLocation = locationLabel.text else {
//        return false
//      }
//      
//      var description: String = ""
//      if vehicleDescriptionTextView.text.isEmpty {
//        description = "Awesome car to rent"
//      } else {
//        description = vehicleDescriptionTextView.text
//      }
//      
//      if carModel == "Select Vehicle Model" || carYear == "Select Vechile Year" || transmission == "Select Transmission" || color == "Select Color" || plateNumber.isEmpty {
//        displayAlert()
//        return false
//      } else {
//        let realm = try! Realm()
//        
//        try! realm.write() {
//          realm.create(OwnerVehicle.self, value: ["vehicle_detail_id": 10, "year": carYear, "transmission": transmission, "color": color, "desription": description], update: true)
//        }
//        return true
//      }
//    }
//    return true
//  }
//  
  func displayAlert() {
    let alertController = UIAlertController(title: "", message: "Please fill in all the fields. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

}

extension AddVehicleDetailViewController: GeneralSelectionProtocol {
  func selectedItem(item: String, type: String) {
    switch type {
    case VehicleDetailSelectionType.model.rawValue:
      self.modelLabel.text = item
    case VehicleDetailSelectionType.year.rawValue:
      self.yearLabel.text = item
    case VehicleDetailSelectionType.transmission.rawValue:
      self.transmissionLabel.text = item
    case VehicleDetailSelectionType.color.rawValue:
      self.colorLabel.text = item
    default:
      return
    }
  }
}
