//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import GoogleMaps
import PKHUD
import Alamofire
import ObjectMapper
import RealmSwift

class BookingDetailViewController: UIViewController {
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
  
  let viewModel = BookingDetailViewModel()
  var booking: Bookings?
  var delegate: PaymentButtonDelegate?
  var paymentURL: String = ""
  let moovbyProvider = MoovbyProvider()
  let realm = try! Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    requestVehicle { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadBooking(booking: self.booking!)
        self.loadMap(latitude: self.viewModel.latitude(), longitude: self.viewModel.longitude())
        self.startDateLabel.text = self.viewModel.startDate()
        self.endDateLabel.text = self.viewModel.endDate()
        self.durationLabel.text = self.viewModel.duration()
        self.bookingStatusLabel.text = self.viewModel.bookingStatus()
        self.vehicleTypeLabel.text = self.viewModel.carTitle()
        self.plateNumberLabel.text = self.viewModel.plateNumber()
        self.totalAmountLabel.text = self.viewModel.totalAmount()
        
        if self.viewModel.bookingStatus() == "Requested" {
          self.leftButton.setTitle("Cancel", for: .normal)
          self.leftButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        } else if (self.viewModel.bookingStatus() == "Confirmed" || self.viewModel.bookingStatus() == "Awaiting Payment") {
          self.leftButton.setTitle("Cancel", for: .normal)
          self.leftButton.backgroundColor = UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0)
          self.rightButton.setTitle("Pay Now", for: .normal)
        } else if self.viewModel.bookingStatus() == "Paid" {
          self.leftButton.setTitle("Smart Key", for: .normal)
          self.leftButton.backgroundColor = UIColor.lightGray
          self.leftButton.isUserInteractionEnabled = false
          self.rightButton.setTitle("Help", for: .normal)
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
    self.navigationItem.title = "Booking Details"
  }
  
  static func instantiate() -> BookingDetailViewController {
    return UIStoryboard(name: "BoookingDetailStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BookingDetailViewController") as! BookingDetailViewController
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
    if leftButton.titleLabel?.text == "Cancel" {
      cancelConfirmationAlert()
    } else if leftButton.titleLabel?.text == "Help" {
      callCustomerSupport()
    }
  }
  
  @IBAction func rightButtonTapped(_ sender: Any) {
    if rightButton.titleLabel?.text == "Help" {
      callCustomerSupport()
    } else if rightButton.titleLabel?.text == "Pay Now" {
      self.requestBookingPayment(completion: { (success) in
        if success {
          HUD.hide()
          let paymentViewController = PaymentViewController.instantiate()
          let navigationController = UINavigationController(rootViewController: paymentViewController)
          self.navigationController?.present(navigationController, animated: true, completion: nil)
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
    Alamofire.request("\(moovbyProvider.baseURL)/vehicles/\((booking?.vehicleId)!)", headers: moovbyProvider.headers()).responseJSON { (response) in
      
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

  
  func requestBookingPayment(completion: @escaping (_ success: Bool) -> Void) {
    HUD.show(.progress)
    
    Alamofire.request("\(moovbyProvider.baseURL)/bookings/\((booking?.id)!)/payment", headers: moovbyProvider.headers()).responseJSON { (response) in
      if response.response?.statusCode == 200 {
        let payments = RealmRepository().objects(type: Payment.self)
        let paymentResults = RealmRepository().objects(type: PaymentResult.self)
        let result = Mapper<PaymentResult>().map(JSON: response.result.value as! [String: Any], toObject: PaymentResult())
        try! self.realm.write {
          if !payments.isEmpty {
            for payment in payments {
              RealmRepository().deleteObject(object: payment)
            }
          }
          
          if !paymentResults.isEmpty {
            for paymentResult in paymentResults {
              RealmRepository().deleteObject(object: paymentResult)
            }
          }
          
          self.realm.add(result, update: true)
        }
        
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Fail to request payment", message: "Sorry, something went wrong. Please check your booking in My Booking or try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  func requestCancelBooking(reason: String, completion: @escaping (_ success: Bool) -> Void) {
    let urlString = "\(moovbyProvider.baseURL)/bookings/\(self.viewModel.bookingId())/cancel"
    
    let params: Parameters = [
      "reason": reason
    ]
    
    Alamofire.request(urlString, method: .put, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<BookingResult>().map(JSON: response.result.value as! [String: Any], toObject: BookingResult())
        try! self.realm.write {
          self.realm.add(result, update: true)
        }
        
        DispatchQueue.main.async {
          self.bookingStatusLabel.text = "Cancelled"
          self.leftButton.setTitle("Help", for: .normal)
          self.leftButton.backgroundColor = UIColor.moovbyGreen
          self.rightButtonWidthConstraint.constant = 0
          self.spaceConstraint.constant = 0
        }
        
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Fail to cancel booking", message: "Sorry, something went wrong. Please check your booking in My Booking or try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
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
    let alertController = UIAlertController(title: "Cancel Booking", message: "Are you sure you want to cancel the booking?", preferredStyle: UIAlertControllerStyle.alert)
    
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
    let alert = UIAlertController(title: "Cancel Booking", message: "Please provide the reason of booking cancellation. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
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
        
        self.requestCancelBooking(reason: reason, completion: { (success) in
          if success {
            HUD.hide()
            let notificationName = Notification.Name("CancelBookingNotificationIdentifier")
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
    let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please check your network connection and try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
