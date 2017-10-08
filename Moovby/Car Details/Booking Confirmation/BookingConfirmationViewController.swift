//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import RealmSwift
import PKHUD
import GoogleMaps
import CoreLocation

class BookingConfirmationViewController: UIViewController {
  @IBOutlet var confirmationButton: UIButton!
  @IBOutlet var bookingStartDate: UILabel!
  @IBOutlet var bookingEndDate: UILabel!
  @IBOutlet var bookingDuration: UILabel!
  @IBOutlet var totalBookingPrice: UILabel!
  @IBOutlet weak var addPromoCodeButton: UIButton!
  @IBOutlet weak var promoCodeLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
  
  let realm = try! Realm()
  let moovbyProvider = MoovbyProvider()
  var car: Car?
  var vehicleDetail: VehicleDetail?
  var bookingTableViewController: BookingInfoTableViewController?
  let viewModel = BookingConfirmationViewModel()
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    confirmationButton.layer.cornerRadius = 5
    self.viewModel.loadBookings(vehicleId: (car?.id)!)
    self.loadMap(latitude: self.viewModel.latitude(), longitude: self.viewModel.longitude())

    bookingStartDate.text = dateStringToString(date: selectedStartDate)
    bookingEndDate.text = dateStringToString(date: selectedEndDate)
    bookingDuration.text = viewModel.duration()
    totalBookingPrice.text = viewModel.totalPrice()
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func confirmationButtonDidTapped(_ sender: Any) {
    HUD.show(.progress)
    requestBookingConfirmation { (success) -> Void in
      if success {
        HUD.hide()
        self.presentBookingViewController()
      }
      HUD.hide()
    }
  }
  
  @IBAction func addPromoCodeButtonDidTapped(_ sender: Any) {
    presentAddPromoCodeAlertController()
  }
  
  func requestBookingConfirmation(completion: @escaping (_ success: Bool) -> Void) {
    let urlString = "\(moovbyProvider.baseURL)/bookings/\(self.viewModel.bookingId())/confirm"
    
    Alamofire.request(urlString, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      
      if response.response?.statusCode == 200 {
        let result = Mapper<BookingResult>().map(JSON: response.result.value as! [String: Any], toObject: BookingResult())
        try! self.realm.write {
          self.realm.add(result, update: true)
        }
        
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Fail to confirm booking", message: "Sorry, something went wrong. Please try again later or check your booking in My Booking. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  func requestPromoCodeConfirmation(promoCode: String, completion: @escaping (_ success: Bool) -> Void) {
    let url = "\(moovbyProvider.baseURL)/bookings/\(self.viewModel.bookingId())/promo"
    
    let params: Parameters = [ "code" : promoCode ]
    
    Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      if response.response?.statusCode == 200 {
        print(response.result.value as! [String : Any])
        
        do {
          if let json = try JSONSerialization.jsonObject(with: response.data!, options:.allowFragments) as? [String:Any] {
            print("jsonnn: \(json)")
            let bookingsDictionary = json["bookings"] as! [String:Any]
            let totalAfterPromo = bookingsDictionary["total_after_promo"] as! String
            print(totalAfterPromo)
            
            DispatchQueue.main.async {
              self.addPromoCodeButton.isHidden = true
              self.promoCodeLabel.text = promoCode
              self.totalBookingPrice.text = String(format: "RM %.2f", Double(totalAfterPromo)!)
            }
          }
        } catch let err{
          print(err.localizedDescription)
        }
        completion(true)
      } else {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Oops!", message: "Invalid promo code. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  func presentBookingViewController() {
    let bookingViewController = BookingViewController.instantiate()
    self.navigationController?.pushViewController(bookingViewController, animated: true)
  }
  
  func presentAddPromoCodeAlertController() {
    let alert = UIAlertController(title: "Add Promo Code", message: "Enter promo code here", preferredStyle: UIAlertControllerStyle.alert)
      alert.addTextField { (configurationTextField) in
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
      (result : UIAlertAction) -> Void in
    }
    alert.addAction(cancelAction)
    
    alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
      if let textField = alert.textFields?.first {
        HUD.show(.progress)
        var promoCode = ""
        if (textField.text?.isEmpty)! {
          promoCode = ""
        } else {
          promoCode = textField.text!
        }
        
        self.requestPromoCodeConfirmation(promoCode: promoCode, completion: { (success) in
          if success {
            HUD.hide()
          }
          HUD.hide()
        })
      }
    }))
    self.present(alert, animated: true, completion: {
      print("completion block")
    })
  }
  
  @IBAction func mapViewButtonDidTap(_ sender: Any) {
    if (UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!)) {
      UIApplication.shared.openURL(URL(string:
        "https://maps.google.com/?q=\(viewModel.latitude()),\(viewModel.longitude())")!)
    } else {
      print("Can't use comgooglemaps://");
    }
  }
  
  //  for the textlabel
  func dateStringToString(date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let myDate = dateFormatter.date(from: date)
    
    dateFormatter.dateFormat = "dd MMM yyyy, h:mm a"
    let somedateString = dateFormatter.string(from: myDate!)
    return somedateString
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
}
