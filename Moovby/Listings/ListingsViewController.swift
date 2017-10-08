//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Alamofire
import ObjectMapper
import RealmSwift

class ListingsViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

  // MARK: - Outlets

  @IBOutlet weak var tableView: UITableView!

  // MARK: - Properties

  let cellReuseIdentifier = "ListingTableViewCell"
  let moovbyProvider = MoovbyProvider()
  let viewModel = CarListViewModel()
  var cars: [Car] = []
  lazy var realm: Realm = {
    return try! Realm()
  }()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Listings"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    requestCarList()
    viewModel.loadCars()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
  }

  // MARK: - Actions

  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  static func instantiate() -> ListingsViewController {
    return UIStoryboard(name: "ListingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ListingsViewController") as! ListingsViewController
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "You have no car listed. \nClick '+' to list your car.")
  }

  // MARK: - DZNEmptyDataSetDelegate

  deinit {
    tableView.emptyDataSetSource = nil
    tableView.emptyDataSetDelegate = nil
  }
}

extension ListingsViewController {
  fileprivate func configureUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    tableView.tableFooterView = UIView()

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedButtonAdd))
    self.navigationItem.rightBarButtonItem = addButton
  }

  func requestCarList() {
    let userRepo = UserLoginRepository().users().first
    guard let userId = userRepo?.id else { return }
    let url = "\(moovbyProvider.baseURL)/users/\(userId)/vehicles"
    let headers = self.moovbyProvider.headers()

    Alamofire.request(url, headers: headers).responseJSON { response in
      guard let statusCode = response.response?.statusCode else { return }
      if statusCode == 200 {
        if let json = response.result.value as? [String: Any] {
          print("JSON: ", json)
          guard let result = Mapper<Car>().mapArray(JSONArray: json["user_vehicles"] as! [[String: Any]]) else { return }
          try! self.realm.write {
            self.realm.add(result, update: true)
          }
          self.cars = result
          self.tableView.reloadData()
        }
      }
    }

  }

  func tappedButtonAdd() {
    let controller = MakersController(nibName: "MakersController", bundle: nil)
    self.navigationController?.pushViewController(controller, animated: true)
  }
}

// MARK: - UITableView Data Source

extension ListingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cars.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier,
                                             for: indexPath) as! ListingTableViewCell
    let car = cars[indexPath.row]
    print("CAR ID: ", car.id)
    print("MAKE: ", VehicleRepository().carById(carId: car.id))

    guard let model = VehicleRepository().carById(carId: car.id) else {
      return cell
    }
    guard let make = VehicleDetailRepository().vehicleDetailById(vehicleDetailId: model.vehicleDetailId) else {
      return cell
    }
    cell.configureCellFor(car: car, details: make)
    
    return cell
  }
}

// MARK: - UITableView Delegates

extension ListingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
}
