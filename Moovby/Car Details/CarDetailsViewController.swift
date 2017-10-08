//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import RealmSwift
import Kingfisher
import GoogleMaps
import PKHUD

class CarDetailsViewController: UIViewController, GMSMapViewDelegate {

  // MARK: - Outlets

  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var titleContainer: UIView!
  @IBOutlet var hourlyRateLabel: UILabel!
  @IBOutlet var requestButton: UIButton!
  @IBOutlet var transmissionLabel: UILabel!
  @IBOutlet var yearLabel: UILabel!
  @IBOutlet var colorLabel: UILabel!
  @IBOutlet var descriptionTextView: UITextView!
  @IBOutlet var pickupAddressLabel: UILabel!
  @IBOutlet var requestButtonLabel: UILabel!
  @IBOutlet var carTitleLabel: UILabel!
  @IBOutlet var carTypeLabel: UILabel!
  @IBOutlet var pricingDetailsView: UIView!
  @IBOutlet var visualEffectView: UIVisualEffectView!
  @IBOutlet var pricingDetailsHourlyLabel: UILabel!
  @IBOutlet var pricingDetailsDailyLabel: UILabel!
  @IBOutlet var pricingDetailsWeeklyLabel: UILabel!

  // MARK: - Properties
  
  var effect: UIVisualEffect!
  var delegate: SearchProtocol?
  var car: Car?
  var vehicleDetail: VehicleDetail?
  var carTitle: String?
  var isDateSelected: Bool = false
  let realm = try! Realm()
  let moovbyProvider = MoovbyProvider()
  let selector = WWCalendarTimeSelector.instantiate()
  private var confirmationViewController: BookingConfirmationViewController?
  fileprivate var singleDate: Date = Date()
  fileprivate var multipleDates: [Date] = []
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    visualEffectView.isHidden = true
    effect = visualEffectView.effect
    visualEffectView.effect = nil
    pricingDetailsView.layer.cornerRadius = 5
    
    let userProfile = UserProfileRepository().profile()
    
    /*
     * If userProfile entry is > 1, check if the entry index 1 is verified.
     * else if it isVerified = true, remove entry index 0 and update booking button.
     * Else if userProfile entry only 1, check if isVerified = false, requestUserProfile
     * and update booking button state.
     */
    if userProfile.count > 1 {
      let renterVerified = userProfile[1].isVerified
      
      if !renterVerified {
        requestUserProfile { (success) in
          HUD.show(.progress)
          if success {
            HUD.hide()
            self.setRequestButtonLabel(isDateSelected: self.isDateSelected)
          }
        }
      } else {
        try! realm.write {
          let items = [UserProfile]()
          let ids = items.map { $0.id }
          let objectsToDelete = realm.objects(UserProfile.self).filter("id = 0", ids)
          realm.delete(objectsToDelete)
        }
        self.setRequestButtonLabel(isDateSelected: self.isDateSelected)
      }
    } else if userProfile.isEmpty {
      // TODO: Handle when userProfile is empty
    } else {
      let renterVerified = userProfile[0].isVerified
      
      if !renterVerified {
        requestUserProfile { (success) in
          HUD.show(.progress)
          if success {
            HUD.hide()
            self.setRequestButtonLabel(isDateSelected: self.isDateSelected)
          }
        }
      } else {
        self.setRequestButtonLabel(isDateSelected: self.isDateSelected)
      }
    }
    
    guard let car = self.car else {
      return
    }
    guard let vehicleDetail = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: car.vehicleDetailId)
       else {
        return
    }
    self.vehicleDetail = vehicleDetail
    
    let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(car.latitude), longitude: CLLocationDegrees(car.longitude), zoom: 15.0)
    mapView.camera = camera
    let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(car.latitude), longitude: CLLocationDegrees(car.longitude))
    let marker = GMSMarker(position: position)
    marker.map = mapView
    
    do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }

    imageView.kf.setImage(with: URL(string: vehicleDetail.imageUrl))
    transmissionLabel.text = car.transmission
    yearLabel.text = String(car.year)
    colorLabel.text = car.color
    descriptionTextView.text = car.carDescription
    pickupAddressLabel.text = car.address
    hourlyRateLabel.text = "RM \(vehicleDetail.hourlyPrice)0 per hour"
    requestButton.layer.cornerRadius = 5
    setRequestButtonLabel(isDateSelected: isDateSelected)
    carTitleLabel.text = carTitle
    carTypeLabel.text = vehicleDetail.vehicleType.capitalized
    pricingDetailsHourlyLabel.text = "RM \(vehicleDetail.hourlyPrice)0"
    pricingDetailsDailyLabel.text = "RM \(vehicleDetail.dailyPrice)0"
    pricingDetailsWeeklyLabel.text = "RM \(vehicleDetail.weeklyPrice)0"
  }

  func configure(viewModel: CarDetailsViewModel) {
    carTitle = viewModel.title()
  }

  func setRequestButtonLabel(isDateSelected: Bool) {
    if let userProfile = UserProfileRepository().profile().first {
      if userProfile.isVerified {
        requestButtonLabel.text = isDateSelected ? "Book Now" :  "Booking Schedule"
        requestButton.backgroundColor = UIColor.moovbyGreen
      } else if !userProfile.isVerified && !userProfile.drivingLicenseImage.isEmpty && !userProfile.icImage.isEmpty {
        requestButtonLabel.text = "Pending"
        requestButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
      } else {
        requestButtonLabel.text = "Verify"
        requestButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
      }
    } else {
      requestButtonLabel.text = "Verify"
      requestButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
    }
  }
  
  func requestBooking(completion: @escaping (_ success: Bool) -> Void) {
    guard let car = self.car else { return }
    
    let urlString = "\(moovbyProvider.baseURL)/bookings"
    let params: Parameters = [
      "vehicle_id": car.id,
      "starts": selectedStartDate,//"2017-10-29T10:00:00.000+08:00",
      "ends": selectedEndDate,//"2017-10-29T14:00:00.000+08:00",
      "address": car.address,
      "latitude": car.latitude,
      "longitude": car.longitude,
      "platform": "ios"
    ]
    
    Alamofire.request(urlString, method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<BookVehicle>().map(JSON: response.result.value as! [String: Any], toObject: BookVehicle())
        try! self.realm.write {
          self.realm.add(result)
        }
        completion(true)
      } else {
        HUD.hide()
        
        if let JSON = response.result.value as? [String : Any] {
          let errorMessage = JSON["message"] as? String
          let alertController = UIAlertController(title: "Fail to Book", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
          
          let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
          {
            (result : UIAlertAction) -> Void in
          }
          alertController.addAction(okAction)
          self.present(alertController, animated: true, completion: nil)
          self.setRequestButtonLabel(isDateSelected: false)
        }
      }
    }
  }

  func dateToString(date: Date, dateFormat: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat//"M/d/yy, H:mm"
    return dateFormatter.string(from: date)
  }

  func displayPendingAlert() {
    let alertController = UIAlertController(title: "Pending Verification", message: "Hi there, your account is still pending for verification. Please wait and try again shortly.\nShould you have any question, please contact our customer support to assist you", preferredStyle: UIAlertControllerStyle.alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    
    let callAction = UIAlertAction(title: "Call", style: .default) { (UIAlertAction) in
      guard let number = URL(string: "telprompt://+601110055901") else { return }
      if #available(iOS 10.0, *) {
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
      } else {
        UIApplication.shared.openURL(number)
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(callAction)
    self.present(alertController, animated: true, completion: nil)
  }

  func requestUserProfile(completion: @escaping (_ success: Bool) -> Void) {
    let user = UserLoginRepository().users().first
    guard let userID = user?.id else { return }
    print("userID: \(userID)")
    let urlString = "\(moovbyProvider.baseURL)/profiles/\(userID)"
    
    Alamofire.request(urlString, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<UserProfileResult>().map(JSON: response.result.value as! [String : Any], toObject: UserProfileResult())
        
        let realm = try! Realm()
        
        try! realm.write {
          realm.add(result, update: true)
        }
        completion(true)
      } else {
        self.presentAlertController()
        completion(false)
      }
      
    }
  }

  // MARK: - Actions

  @IBAction func requestButtonDidTapped(_ sender: Any) {
    guard let buttonType = requestButtonLabel.text else { return }
    switch buttonType {
    case "Verify":
      profileVerificationButtonTapped()
    case "Pending":
      displayPendingAlert()
    case "Booking Schedule":
      selectDuration()
      self.delegate?.updateDateSelected(isSelected: true)
    case "Book Now":
      HUD.show(.progress)
      requestBooking(completion: { (success) in
        if success {
          HUD.hide(afterDelay: 1.0)
          self.presentConfirmationVC()
        }
      })
    default:
      break
    }
  }

  @IBAction func viewMapButtonDidTapped(_ sender: Any) {
    guard let car = self.car else { return }

    if (UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!)) {
      UIApplication.shared.openURL(URL(string:
        "https://maps.google.com/?q=\(CLLocationDegrees(car.latitude)),\(CLLocationDegrees(car.longitude))")!)
    } else {
      print("Can't use comgooglemaps://");
    }
  }

  @IBAction func pricingDetailsButtonDidTapped(_ sender: Any) {
    // Animate in
    visualEffectView.isHidden = false
    self.view.addSubview(pricingDetailsView)
    pricingDetailsView.center = self.view.center

    pricingDetailsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
    pricingDetailsView.alpha = 0

    UIView.animate(withDuration: 0.4) {
      self.visualEffectView.effect = self.effect
      self.pricingDetailsView.alpha = 1
      self.pricingDetailsView.transform = CGAffineTransform.identity
    }
  }

  @IBAction func dismissPopUpButtonDidTapped(_ sender: Any) {
    // Animate out
    UIView.animate(withDuration: 0.3) {
      self.pricingDetailsView.alpha = 1
      self.visualEffectView.effect = nil
      self.visualEffectView.isHidden = true
      self.pricingDetailsView.removeFromSuperview()
    }
  }

  // MARK: - Navigations

  func selectDuration() {
    let durationVC = DurationViewController.instantiate()
    durationVC.delegate = self
    self.navigationController?.pushViewController(durationVC, animated: true)
  }

  func profileVerificationButtonTapped() {
    let profileViewController = NameViewController.instantiate()
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelView))
    profileViewController.navigationItem.rightBarButtonItem = cancelButton
    self.navigationController?.pushViewController(profileViewController, animated: true)
  }

  func presentConfirmationVC() {
    self.confirmationViewController = UIStoryboard(name: "BookingConfirmationStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BookingConfirmationViewController") as? BookingConfirmationViewController
    guard let confirmationViewController = self.confirmationViewController else {
      return
    }
    confirmationViewController.car = self.car
    confirmationViewController.selectedEndDate = self.selectedEndDate
    confirmationViewController.selectedStartDate = self.selectedStartDate
    let navigationController = UINavigationController(rootViewController: confirmationViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
    print("cdv: \(self.selectedStartDate)")
  }

  func presentAlertController() {
    let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please check your network connection and try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  func cancelView() {
    self.dismiss(animated: true, completion: nil)
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "bookingConfirmationSegue" {
      let navigationController = segue.destination as! UINavigationController
      let bookingConfirmationViewController = navigationController.topViewController as! BookingConfirmationViewController
      bookingConfirmationViewController.car = self.car
      bookingConfirmationViewController.selectedStartDate = selectedStartDate
      bookingConfirmationViewController.selectedEndDate = selectedEndDate
    }
  }
}


// MARK: Date range Protocol

extension CarDetailsViewController: DateRangeProtocol {
  func selectedDuration(startDateToAPI: String, endDateToAPI: String, startDateLabel: String, endDateLabel: String) {
    selectedStartDate = startDateToAPI
    selectedEndDate = endDateToAPI
    isDateSelected = true
    setRequestButtonLabel(isDateSelected: isDateSelected)
    print("durationdetails:: \(selectedStartDate) - \(selectedEndDate)")
  }
}

