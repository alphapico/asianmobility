//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import GoogleMaps
import PKHUD
import Alamofire
import ObjectMapper
import RealmSwift

class JobDetailViewController: UIViewController {
  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var startDateLabel: UILabel!
  @IBOutlet var endDateLabel: UILabel!
  @IBOutlet var durationLabel: UILabel!
  @IBOutlet var bookingStatusLabel: UILabel!
  @IBOutlet var vehicleTypeLabel: UILabel!
  @IBOutlet var plateNumberLabel: UILabel!
  @IBOutlet var totalAmountLabel: UILabel!
  @IBOutlet var leftButton: UIButton!
  @IBOutlet var rightButton: UIButton!
  @IBOutlet var leftButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet var rightButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet var spaceConstraint: NSLayoutConstraint!
  
  let viewModel = JobDetailViewModel()
  var job: Jobs?
  var delegate: PaymentButtonDelegate?
  var paymentURL: String = ""
  let moovbyProvider = MoovbyProvider()
  let realm = try! Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    requestVehicle { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadJob(job: self.job!)
        self.loadMap(latitude: self.viewModel.latitude(), longitude: self.viewModel.longitude())
        self.startDateLabel.text = self.viewModel.startDate()
        self.endDateLabel.text = self.viewModel.endDate()
        self.durationLabel.text = self.viewModel.duration()
        self.bookingStatusLabel.text = self.viewModel.jobStatus()
        self.vehicleTypeLabel.text = self.viewModel.carTitle()
        self.plateNumberLabel.text = self.viewModel.plateNumber()
        self.totalAmountLabel.text = self.viewModel.totalAmount()
        
        if self.viewModel.jobStatus() == "Requested" {
          self.leftButton.setTitle("Reject", for: .normal)
          self.leftButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
          self.rightButton.setTitle("Accept", for: .normal)
        } else if (self.viewModel.jobStatus() == "Confirmed" || self.viewModel.jobStatus() == "Awaiting Payment") {
          self.leftButton.setTitle("Reject", for: .normal)
          self.leftButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        } else if self.viewModel.jobStatus() == "Paid" {
          self.leftButton.setTitle("Deliver Vehicle", for: .normal)
          self.rightButton.setTitle("Contact", for: .normal)
        } else if self.viewModel.jobStatus() == "Delivered" {
          self.leftButton.setTitle("Complete Booking", for: .normal)
          self.leftButton.backgroundColor = UIColor.moovbyGreen
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        } else { // Canceled, Rejected, Completed
          self.leftButton.setTitle("Help", for: .normal)
          self.leftButton.backgroundColor = UIColor.moovbyGreen
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "Job Details"
  }
  
  static func instantiate() -> JobDetailViewController {
    return UIStoryboard(name: "JobDetailStoryboard", bundle: nil).instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
  }
  
  func loadMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12.0)
    mapView.camera = camera
    let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
  }
  
  @IBAction func leftButtonTapped(_ sender: Any) {
    if leftButton.titleLabel?.text == "Reject" {
      cancelConfirmationAlert()
    } else if leftButton.titleLabel?.text == "Help" {
      callCustomerSupport()
    } else if leftButton.titleLabel?.text == "Deliver" {
      requestDeliverBooking(completion: { (success) in
        if success {
          HUD.hide()
        }
      })
    } else if leftButton.titleLabel?.text == "Complete Booking" {
      // Submit Review
//      submitReview(completion: { (success) in
//        if success {
//          HUD.hide()
//        }
//      })
    }
  }
  
  @IBAction func rightButtonTapped(_ sender: Any) {
    if rightButton.titleLabel?.text == "Help" {
      callCustomerSupport()
    } else if rightButton.titleLabel?.text == "Accept" {
      self.requestAcceptBooking(completion: { (success) in
        if success {
          HUD.hide()
        }
      })
    }
  }
  
  @IBAction func mapButtonTapped(_ sender: Any) {
    if (UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!)) {
      UIApplication.shared.openURL(URL(string:
        "https://maps.google.com/?q=\(viewModel.latitude()),\(viewModel.longitude())")!)
    } else {
      print("Can't use comgooglemaps://");
    }
  }
  
  func callCustomerSupport() {
    guard let number = URL(string: "telprompt://+601110055901") else { return }
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(number, options: [:], completionHandler: nil)
    } else {
      UIApplication.shared.openURL(number)
    }
  }
  
  func requestVehicle(completion: @escaping(_ success: Bool) -> Void) {
    HUD.show(.progress)
    Alamofire.request("\(moovbyProvider.baseURL)/vehicles/\((job?.vehicleId)!)", headers: moovbyProvider.headers()).responseJSON { (response) in
      
      if response.response?.statusCode == 200 {
        let carResult = Mapper<CarResult>().map(JSON: response.result.value as! [String : Any], toObject: CarResult())
        
        try! self.realm.write {
          self.realm.add(carResult, update: true)
        }
        
        completion(true)
      } else {
        self.presentAlertController()
      }
    }
  }
  
  // MARK: - Accept Booking
  func requestAcceptBooking(completion: @escaping (_ success: Bool) -> Void) {
    let urlString = "\(moovbyProvider.baseURL)/bookings/\(self.viewModel.jobId())/accept"
    
    Alamofire.request(urlString, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<JobResult>().map(JSON: response.result.value as! [String: Any], toObject: JobResult())
        try! self.realm.write {
          self.realm.add(result, update: true)
        }
        
        DispatchQueue.main.async {
          self.bookingStatusLabel.text = "Accepted"
          self.leftButton.setTitle("Contact", for: .normal)
          self.leftButton.backgroundColor = UIColor.moovbyGreen
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        }
        
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Fail to accept booking", message: "Sorry, something went wrong. Please try again later or contact our support. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }

  // MARK: - Rejcet Booking
  func requestRejectBooking(reason: String, completion: @escaping (_ success: Bool) -> Void) {
    let urlString = "\(moovbyProvider.baseURL)/bookings/\(self.viewModel.jobId())/reject"
    
    let params: Parameters = [
      "reason": reason
    ]
    
    Alamofire.request(urlString, method: .put, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<JobResult>().map(JSON: response.result.value as! [String: Any], toObject: JobResult())
        try! self.realm.write {
          self.realm.add(result, update: true)
        }
        
        DispatchQueue.main.async {
          self.bookingStatusLabel.text = "Rejected"
          self.leftButton.setTitle("Contact", for: .normal)
          self.leftButton.backgroundColor = UIColor.moovbyGreen
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        }
        
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Fail to reject booking", message: "Sorry, something went wrong. Please try again later or contact our support. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  // MARK : - Deliver Booking
  func requestDeliverBooking(completion: @escaping (_ success: Bool) -> Void) {
    let urlString = "\(moovbyProvider.baseURL)/bookings/\(self.viewModel.jobId())/deliver"
    
    Alamofire.request(urlString, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<JobResult>().map(JSON: response.result.value as! [String: Any], toObject: JobResult())
        try! self.realm.write {
          self.realm.add(result, update: true)
        }
        
        DispatchQueue.main.async {
          self.bookingStatusLabel.text = "Delivered"
          self.leftButton.setTitle("Complete Booking", for: .normal)
          self.leftButton.backgroundColor = UIColor.moovbyGreen
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        }
        
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Fail to deliver booking", message: "Sorry, something went wrong. Please try again later or contact our support. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  // MARK: - Submit Review
  func submitReview(completion: @escaping (_ success: Bool) -> Void) {
    let params: Parameters = [:]
    
    Alamofire.request("\(moovbyProvider.baseURL)/reviews", method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        if let result = response.result.value {
          let JSON = result as! NSDictionary
          print("json: \(JSON)")
        }
        
        completion(true)
      } else {
        HUD.hide()
        let alertController = UIAlertController(title: "Fail to Submit Review", message: "Sorry, please try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  func cancelConfirmationAlert() {
    let alertController = UIAlertController(title: "Reject Booking", message: "Are you sure you want to reject the booking?", preferredStyle: UIAlertControllerStyle.alert)
    
    let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
      (result : UIAlertAction) -> Void in
    }
    
    let continueAction = UIAlertAction(title: "Yes, Please.", style: UIAlertActionStyle.default) {
      (UIAlertAction) in
      
      self.presentCancellationReasonController()
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(continueAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func presentCancellationReasonController() {
    let alert = UIAlertController(title: "Reject Booking", message: "Please provide the reason of booking rejection. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
    /*let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
     (result : UIAlertAction) -> Void in
     }
     alert.addAction(cancelAction)*/
    alert.addTextField { (configurationTextField) in
    }
    
    alert.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
      if let textField = alert.textFields?.first {
        HUD.show(.progress)
        var reason = ""
        if (textField.text?.isEmpty)! {
          reason = "User cancelled booking"
        } else {
          reason = textField.text!
        }
        
        self.requestRejectBooking(reason: reason, completion: { (success) in
          if success {
            HUD.hide()
            let notificationName = Notification.Name("RejectBookingNotificationIdentifier")
            NotificationCenter.default.post(name: notificationName, object: nil)
          }
          HUD.hide()
        });
      }
    }))
    self.present(alert, animated: true, completion: {
      print("completion block")
    })
  }
  
  func presentAlertController() {
    HUD.hide()
    let alertController = UIAlertController(title: "Oops!", message: "Fail to load job listing. Please try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
