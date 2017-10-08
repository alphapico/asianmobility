//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import RealmSwift
import CoreLocation

class FilterViewController: UIViewController, CarTypeProtocol, CarModelProtocol {
  @IBOutlet var carModelViewContainer: UIView!
  @IBOutlet var carTypeViewContainer: UIView!
  @IBOutlet var applyButton: UIButton!
  @IBOutlet var vehicleTypeLabel: UILabel!
  @IBOutlet var vehicleBrandLabel: UILabel!
  @IBOutlet weak var driveForUberCheckbox: CheckBox!
  
  var selectedCarType: String?
  var selectedCarModel: String?
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  var delegate: SearchProtocol?
  var latitude: CLLocationDegrees?
  var longitude: CLLocationDegrees?
  var place: String?
  var isUber: Bool = false
  let moovbyProvider = MoovbyProvider()
  let realm = try! Realm()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpView()
  }
  
  func setUpView() {
    vehicleTypeLabel.text = (selectedCarType == nil || selectedCarType == "") ? "All vehicle types" : selectedCarType?.uppercased()
    vehicleBrandLabel.text = (selectedCarModel == nil || selectedCarModel == "") ? "All vehicle brands" : selectedCarModel?.uppercased()
    driveForUberCheckbox.isChecked = isUber
    
    carModelViewContainer.layer.borderColor = UIColor.moovbyGreen.cgColor
    carModelViewContainer.layer.borderWidth = 1
    carModelViewContainer.layer.cornerRadius = 3
    
    carTypeViewContainer.layer.borderColor = UIColor.moovbyGreen.cgColor
    carTypeViewContainer.layer.borderWidth = 1
    carTypeViewContainer.layer.cornerRadius = 3
    
    applyButton.layer.cornerRadius = applyButton.frame.height/2
  }
  
  func selectedCarType(carType: String) {
    selectedCarType = carType
    vehicleTypeLabel.text = carType
  }
  
  func selectedCarModel(carModel: String) {
    selectedCarModel = carModel
    vehicleBrandLabel.text = carModel
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func applyButtonDidTapped(_ sender: Any) {
    guard let place = place, let latitude = latitude,
      let longitude = longitude else { return }
    
    let selectedType = self.selectedCarType == nil ? "" : self.selectedCarType?.lowercased()
    let selectedBrand = self.selectedCarModel == nil ? "" : self.selectedCarModel?.lowercased()
    let startDate = self.selectedStartDate
    let endDate = self.selectedEndDate
    
    self.delegate?.updateSearchResult(place: place, latitude: latitude, longitude: longitude, vehicleType: selectedType!, vehicleBrand: selectedBrand!, startDate: startDate, endDate: endDate, isUber: driveForUberCheckbox.isChecked)
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func driveForUberButtonDidTapped(_ sender: Any) {
    if driveForUberCheckbox.isChecked == false {
      driveForUberCheckbox.setImage(UIImage(named: "checked-green"), for: .normal)
    } else {
      driveForUberCheckbox.setImage(UIImage(named: "unchecked-green"), for: .normal)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "vehicleTypeSegue" {
      let viewController = (segue.destination as! CarTypeViewController)
      viewController.delegate = self
    } else if segue.identifier == "vehicleBrandSegue" {
      let viewController = (segue.destination as! CarModelViewController)
      viewController.delegate = self
    }
  }
  @IBAction func resetButtonDidTapped(_ sender: Any) {
    vehicleTypeLabel.text = "All vehicle types"
    vehicleBrandLabel.text = "All vehicle brands"
    selectedCarType = ""
    selectedCarModel = ""
  }
}
