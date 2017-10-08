//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Alamofire
import RealmSwift
import ObjectMapper
import PKHUD

protocol PaymentButtonDelegate {
  func paymentButtonDidTapped()
}

class BookingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, PaymentButtonDelegate {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet var bookingTableView: UITableView!
  let cellReuseIdentifier = "BookingsTableViewCell"
  let viewModel = BookingViewModel()
  let moovbyProvider = MoovbyProvider()
  let realm = try! Realm()
  let notificationName = Notification.Name(rawValue: "CancelBookingNotificationIdentifier")
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "My Bookings"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bookingTableView.emptyDataSetSource = self
    bookingTableView.emptyDataSetDelegate = self
    
    bookingTableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
    bookingTableView.rowHeight = UITableViewAutomaticDimension
    bookingTableView.estimatedRowHeight = 250
    bookingTableView.tableFooterView = UIView()
    
    NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: notificationName, object: nil)
    
    requestCurrentBooking { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadBookings()
        self.bookingTableView.reloadData()
      }
      HUD.hide()
    }
    
    bookingTableView.reloadData()
  }
  
  func refreshView() {
    requestCurrentBooking { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadBookings()
        self.bookingTableView.reloadData()
      }
      HUD.hide()
    }
    
    bookingTableView.reloadData()
  }
  
  @IBAction func homeButtonDidTapped(_ sender: Any) {
    self.performSegue(withIdentifier: "unwindToViewController", sender: self)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch segmentedControl.selectedSegmentIndex
    {
    case 0:
      self.viewModel.loadBookings()
    case 1:
      self.viewModel.loadPastBooking()
    default:
      break
    }
    return viewModel.numberOfItems()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch segmentedControl.selectedSegmentIndex
    {
    case 0:
      self.viewModel.loadBookings()
    case 1:
      self.viewModel.loadPastBooking()
    default:
      break
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    guard let bookingCell = cell as? BookingsTableViewCell,
      let booking = viewModel.itemAtIndex(index: indexPath.row) else {
        return UITableViewCell()
    }
    bookingCell.configure(viewModel: BookingCellViewModel(booking: booking))
    bookingCell.delegate = self
    
    return bookingCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let bookingItem = viewModel.itemAtIndex(index: indexPath.row)
    let bookingDetailViewController = BookingDetailViewController.instantiate()
    bookingDetailViewController.booking = bookingItem
    self.navigationController?.pushViewController(bookingDetailViewController, animated: true)
  }
  
  static func instantiate() -> BookingViewController {
    return UIStoryboard(name: "BookingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BookingViewController") as! BookingViewController
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "You haven't book any car yet.")
  }
  
  // MARK: - DZNEmptyDataSetDelegate
  deinit {
    bookingTableView.emptyDataSetSource = nil
    bookingTableView.emptyDataSetDelegate = nil
    NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
  }
  
  @IBAction func segmentedIndexChanged(_ sender: Any) {
    bookingTableView.reloadData()
  }
  
  func paymentButtonDidTapped() {
    let paymentViewController = PaymentViewController.instantiate()
    let navigationController = UINavigationController(rootViewController: paymentViewController)
    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }
  
  func requestCurrentBooking(completion: @escaping(_ success: Bool) -> Void) {
    HUD.show(.progress)
    Alamofire.request("\(moovbyProvider.baseURL)/bookings?status=current", headers: moovbyProvider.headers()).responseJSON { (response) in
      
      if response.response?.statusCode == 200 {
        let bookingResult = RealmRepository().objects(type: BookingResult.self).first
        let bookings = RealmRepository().objects(type: Bookings.self)
        
        let currentBookings = Mapper<BookingResult>().map(JSON: response.result.value as! [String : Any], toObject: BookingResult())
        
        try! self.realm.write {
          for booking in bookings {
            RealmRepository().deleteObject(object: booking)
          }
          if bookingResult != nil {
            RealmRepository().deleteObject(object: bookingResult!)
          }
          self.realm.add(currentBookings, update: true)
        }
        
        completion(true)
      } else {
        HUD.hide()
        self.presentAlertController()
      }
    }
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
