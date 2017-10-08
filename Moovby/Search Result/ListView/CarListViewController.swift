//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CoreLocation

class CarListViewController: UIViewController {
  
  @IBOutlet var carListTableView: UITableView!
  let viewModel = CarListViewModel()
  var isDateSelected: Bool = false
  var selectedStartDate: String = ""
  var selectedEndDate: String = ""
  let locationManager = CLLocationManager()
  var latitude: CLLocationDegrees = 0.0
  var longitude: CLLocationDegrees = 0.0

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.loadCars()

    carListTableView.emptyDataSetDelegate = self
    carListTableView.emptyDataSetSource = self
    
    carListTableView.register(UINib(nibName: "CarTableViewCell", bundle: nil), forCellReuseIdentifier: "CarTableViewCell")
    carListTableView.rowHeight = UITableViewAutomaticDimension
    carListTableView.estimatedRowHeight = 200
    carListTableView.tableFooterView = UIView()
    
    carListTableView.reloadData()
  }

  // MARK: - Actions

  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  deinit {
    carListTableView.emptyDataSetSource = nil
    carListTableView.emptyDataSetDelegate = nil
  }
}

// MARK: - UITableView Data Source

extension CarListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CarTableViewCell", for: indexPath)
    guard let carCell = cell as? CarTableViewCell,
      let car = viewModel.itemAtIndex(index: indexPath.row) else {
        return UITableViewCell()
    }
    carCell.userLatitude = latitude
    carCell.userLongitude = longitude
    carCell.configure(viewModel: CarCellViewModel(car: car))
    return carCell
  }
}

// MARK: - UITableView Delegates

extension CarListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let carDetailsViewController = UIStoryboard(name: "CarDetailsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "CarDetailsViewController") as? CarDetailsViewController,
      let car = viewModel.itemAtIndex(index: indexPath.row) else {
        return
    }
    carDetailsViewController.car = car
    carDetailsViewController.isDateSelected = isDateSelected
    carDetailsViewController.selectedStartDate = selectedStartDate
    carDetailsViewController.selectedEndDate = selectedEndDate
    carDetailsViewController.configure(viewModel: CarDetailsViewModel(car: car))
    self.navigationController?.pushViewController(carDetailsViewController, animated: true)
  }
}

//MARK: - DZNEmptyDataSet Sources

extension CarListViewController: DZNEmptyDataSetSource {
  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "Oops!")
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "Sorry, there's no car available.")
  }
}

//MARK: - DZNEmptyDataSet Delegates

extension CarListViewController: DZNEmptyDataSetDelegate {}
