//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import RealmSwift
import ObjectMapper

class ViewController: UIViewController, SearchProtocol {

  // MARK: - Outlets

  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var optionsContainer: UIView!
  @IBOutlet var searchBarContainer: UIView!
  @IBOutlet var currenLocationButton: UIButton!
  @IBOutlet var searchCriteriaLabel: UILabel!

  // MARK: - Properties

  var locationManager = CLLocationManager()
  var latitude: CLLocationDegrees = 0.0
  var longitude: CLLocationDegrees = 0.0
  var carType: String?
  var carBrand: String?
  var isDateSelected: Bool = false
  var isZoomedIn: Bool = false
  var rentStartDate: String = ""
  var rentEndDate: String = ""
  var account: Int = Role.sharedInstance.userRole
  var isUber: Bool = false

  private var carDetailsViewController: CarDetailsViewController?
  private var carListViewController: CarListViewController?
  let moovbyProvider = MoovbyProvider()
  lazy var realm: Realm = {
    return try! Realm()
  }()
  let navigationDrawerRearView = UIView()
  let tableView: UITableView = {
    let tv = UITableView(frame: .zero)
    return tv
  }()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
  }

  override func viewDidLoad() {

    super.viewDidLoad()
    askLocationPermission()
    updateUserLocation()
    requestUserProfile { (success) in
      self.fetchMaker()
      self.fetchVehicleDetail()
      self.fetchSearchResult()
    }

    tableView.register(UINib(nibName: "NavigationDrawerCell", bundle: nil), forCellReuseIdentifier: "NavigationDrawerCell")
    tableView.register(UINib(nibName: "CustomHeaderCell", bundle: nil), forCellReuseIdentifier: "customHeaderCell")

    tableView.delegate = self
    tableView.dataSource = self

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200
    tableView.tableFooterView = UIView()
    tableView.reloadData()

    optionsContainer.layer.cornerRadius = 22.5
    addShadowLayer(uiView: optionsContainer, radius: 22.5)

    searchBarContainer.layer.cornerRadius = 5
    addShadowLayer(uiView: searchBarContainer, radius: 5)

    let camera = GMSCameraPosition.camera(withLatitude: 3.1172376, longitude: 101.6783782, zoom: 14.0)
    mapView.camera = camera
    mapView.delegate = self
    mapView.isMyLocationEnabled = true

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

  // MARK: - Private Function

  func askLocationPermission() {
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestLocation()
      locationManager.startUpdatingLocation()
      locationManager.startMonitoringSignificantLocationChanges()
    }
  }

  func updateUserLocation() {
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }

  func addShadowLayer(uiView: UIView, radius: CGFloat) {
    uiView.layer.rasterizationScale = UIScreen.main.scale
    uiView.layer.shadowColor = UIColor.black.cgColor
    uiView.layer.shadowOpacity = 0.3
    uiView.layer.shadowOffset = CGSize(width: 3, height: 3)
    uiView.layer.shadowRadius = 1
    uiView.layer.shouldRasterize = true
  }

  func animateCamera(zoom: Float) {
    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
    mapView.animate(to: camera)
  }

  func updateSearchResult(place: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, vehicleType: String, vehicleBrand: String, startDate: String, endDate: String, isUber: Bool) {
    carType = vehicleType
    carBrand = vehicleBrand
    rentStartDate = startDate
    rentEndDate = endDate
    searchCriteriaLabel.text = place

    if startDate.isEmpty {
      updateDateSelected(isSelected: false)
    } else {
      updateDateSelected(isSelected: true)
    }

    print("vc:: \(startDate) - \(endDate)")
    Alamofire.request("\(moovbyProvider.baseURL)/vehicles?location_latitude=\(latitude)&location_longitude=\(longitude)&type=\(vehicleType)&brand=\(vehicleBrand)&begin_at=\(startDate)&end_at=\(endDate)&is_uber=\(isUber)", headers: self.moovbyProvider.headers()).responseJSON { response in

      if response.response?.statusCode == 200 {
        let searches = RealmRepository().objects(type: SearchResult.self).first
        let cars = RealmRepository().objects(type: Car.self)

        let result = Mapper<SearchResult>().map(JSON: response.result.value as! [String : Any], toObject: SearchResult())
        try! self.realm.write {
          for car in cars {
            RealmRepository().deleteObject(object: car)
          }
          if searches != nil {
            RealmRepository().deleteObject(object: searches!)
          }
          self.realm.add(result, update: true)
        }
        self.mapView.clear()

        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let searchMarker = GMSMarker(position: position)
        searchMarker.map = self.mapView

        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12)
        self.mapView.animate(to: camera)

        for marker in VehicleRepository().vehicles() {
          let marker = MapMarker(car: marker)
          marker.map = self.mapView
        }
      } else {
        self.presentAlertController()
      }
    }
  }

  func fetchSearchResult() {
    Alamofire.request("\(moovbyProvider.baseURL)/vehicles?location_latitude=\(latitude)&location_longitude=\(longitude)", headers: moovbyProvider.headers()).responseJSON { response in

      if response.response?.statusCode == 200 {
        let result = Mapper<SearchResult>().map(JSON: response.result.value as! [String : Any], toObject: SearchResult())
        try! self.realm.write {
          self.realm.add(result, update: true)
        }

        self.mapView.clear()

        let camera = GMSCameraPosition.camera(withLatitude: self.latitude, longitude: self.longitude, zoom: 12) //3.0748967, 101.6438697
        self.mapView.animate(to: camera)
        
        for marker in VehicleRepository().vehicles() {
          let marker = MapMarker(car: marker)
          marker.map = self.mapView
        }
      } else {
        self.presentAlertController()
      }
    }
  }

  func dismissNavigationDrawer() {
    UIView.animate(withDuration: 0.5) {
      self.navigationDrawerRearView.alpha = 0

      if let window = UIApplication.shared.keyWindow {
        self.tableView.frame = CGRect(x: -(window.frame.width), y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height)
      }
    }
  }

  func presentUserProfileViewController(gestureRecognizer: UITapGestureRecognizer) {
    dismissNavigationDrawer()
    let userProfileViewController = UserProfileViewController.instantiate()
    let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
    navigationController.viewControllers = [userProfileViewController]

    self.present(navigationController, animated: true, completion: nil)
  }

  func switchMenu() {
    account = (account == RoleType.Renter.rawValue) ? RoleType.Owner.rawValue : RoleType.Renter.rawValue
    Role.sharedInstance.userRole = account
    tableView.reloadData()

    let controller = HostController(nibName: "HostController", bundle: nil)

    self.navigationController?.viewControllers = [controller]
  }

  func updateDateSelected(isSelected: Bool) {
    isDateSelected = isSelected
  }

  func fetchMaker() {
    Alamofire.request("\(moovbyProvider.baseURL)/makers", headers: moovbyProvider.headers()).responseJSON { (response) in

      if response.response?.statusCode == 200 {
        let makerResult = Mapper<MakerResult>().map(JSON: response.result.value as! [String : Any], toObject: MakerResult())

        try! self.realm.write {
          self.realm.add(makerResult, update: true)
        }
      } else {
        self.presentAlertController()
      }
    }
  }

  func fetchVehicleDetail() {
    Alamofire.request("\(moovbyProvider.baseURL)/vehicles_detail", headers: moovbyProvider.headers()).responseJSON { (response) in

      if response.response?.statusCode == 200 {
        let vehicleDetailResult = Mapper<VehicleDetailResult>().map(JSON: response.result.value as! [String : Any], toObject: VehicleDetailResult())

        try! self.realm.write {
          self.realm.add(vehicleDetailResult, update: true)
        }
      } else {
        self.presentAlertController()
      }
    }
  }

  func requestUserProfile(completion: @escaping (_ success: Bool) -> Void) {
    let user = UserLoginRepository().users().first
    guard let userID = user?.id else { return }

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
      }
    }
  }

  func presentAlertController() {
    let alertController = UIAlertController(
      title: "Oops!",
      message: "Something went wrong. Please check your network connection and try again later. Thank you.",
      preferredStyle: UIAlertControllerStyle.alert
    )
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  // MARK: - Actions

  @IBAction func currentLocationDidTapped(_ sender: Any) {
    updateUserLocation()

    guard let currentLatitude  = locationManager.location?.coordinate.latitude,
      let currentLongitude = locationManager.location?.coordinate.longitude else {
        return
    }

    latitude = currentLatitude
    longitude = currentLongitude

    if isZoomedIn {
      animateCamera(zoom: 12)
      isZoomedIn = false
    } else {
      animateCamera(zoom: 17)
      isZoomedIn = true
    }

    locationManager.stopUpdatingLocation()
  }

  @IBAction func listViewButtonDidTapped(_ sender: Any) {
    carListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CarListViewController") as? CarListViewController

    guard let listViewController = carListViewController else {
      return
    }
    listViewController.isDateSelected = isDateSelected
    listViewController.selectedStartDate = rentStartDate
    listViewController.selectedEndDate = rentEndDate
    listViewController.latitude = latitude
    listViewController.longitude = longitude
//    let navigationController = UINavigationController(rootViewController: carListViewController!)
    let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
    navigationController.viewControllers = [carListViewController!]

    self.navigationController?.present(navigationController, animated: true, completion: nil)
  }

  @IBAction func filterButtonDidTapped(_ sender: Any) {
  }

  @IBAction func unwindToHome(segue: UIStoryboardSegue){}


  @IBAction func navigationDrawerButtonDidTapped(_ sender: Any) {
    if let window = UIApplication.shared.keyWindow {
      navigationDrawerRearView.backgroundColor = UIColor(white: 0, alpha: 0.5)
      navigationDrawerRearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissNavigationDrawer)))
      window.addSubview(navigationDrawerRearView)

      tableView.backgroundColor = UIColor.white
      window.addSubview(tableView)

      let width: CGFloat = window.frame.width - 100
      tableView.frame = CGRect(x: -(window.frame.width), y: 0, width: width, height: window.frame.height)

      navigationDrawerRearView.frame = window.frame
      navigationDrawerRearView.alpha = 0

      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut , animations: {
        self.navigationDrawerRearView.alpha = 1

        self.tableView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height)
      }, completion: nil)
    }
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "filterSegue" {
      let navigationController = segue.destination as! UINavigationController
      let filterViewController = navigationController.topViewController as! FilterViewController
      let place = searchCriteriaLabel.text
      filterViewController.place = place
      filterViewController.latitude = latitude
      filterViewController.longitude = longitude
      filterViewController.selectedCarType = carType
      filterViewController.selectedCarModel = carBrand
      filterViewController.selectedStartDate = rentStartDate
      filterViewController.selectedEndDate = rentEndDate
      filterViewController.isUber = isUber
      filterViewController.delegate = self
    } else if segue.identifier == "searchCriteriaSegue" {
      let navigationController = segue.destination as! UINavigationController
      let searchCriteriaViewController = navigationController.topViewController as! SearchCriteriaViewController
      let place = searchCriteriaLabel.text
      searchCriteriaViewController.locationName = place
      searchCriteriaViewController.latitude = latitude
      searchCriteriaViewController.longitude = longitude
      searchCriteriaViewController.selectedStartDate = rentStartDate
      searchCriteriaViewController.selectedEndDate = rentEndDate
      searchCriteriaViewController.isUber = isUber
      searchCriteriaViewController.delegate = self
    }
  }
}

// MARK: - CLLocationManager Delegates

extension ViewController: CLLocationManagerDelegate {
  func updateLocationCoordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(2.0)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else {
      return
    }
    latitude = location.coordinate.latitude
    longitude = location.coordinate.longitude

    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)

    mapView.animate(to: camera)
    locationManager.stopUpdatingLocation()
  }

  @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
    print("Failed to find user's location: \(error)")
  }
}

// MARK: - UITableView Data Source

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return account == RoleType.Renter.rawValue ? 5 : 6
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(for: indexPath) as NavigationDrawerCell
    let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationDrawerCell", for: indexPath) as! NavigationDrawerCell
    switch indexPath.row {
    case 0:
      cell.titleLabel?.text = account == RoleType.Renter.rawValue ? "My Bookings" : "My Jobs"
      break
    case 1:
      cell.titleLabel?.text = "Inbox"
      break
    case 2:
      cell.titleLabel?.text = account == RoleType.Renter.rawValue ? "Switch to Listing" : "Listings"
      break
    case 3:
      cell.titleLabel?.text = account == RoleType.Renter.rawValue ? "FAQ" : "Switch to Renting"
      break
    case 4:
      cell.titleLabel?.text = account == RoleType.Renter.rawValue ? "Settings" : "FAQ"
      break
    case 5:
      cell.titleLabel?.text = "Settings"
      break
    default:
      return cell
    }
    return cell
  }
}

// MARK: - UITableView Delegates

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let userRepo = UserLoginRepository().users().first
    let userProfileRepo = UserProfileRepository().profile().first
    let headerCell: CustomHeaderCell = tableView.dequeueReusableCell(withIdentifier: "customHeaderCell") as! CustomHeaderCell
    let email = userRepo?.email
    let firstName = userProfileRepo?.firstName
    let lastName = userProfileRepo?.lastName

    if userProfileRepo == nil {
      headerCell.userNameLabel.text = "\(email!)"
    } else {
      headerCell.userNameLabel.text = "\(firstName!) \(lastName!)"
    }

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentUserProfileViewController))
    headerCell.addGestureRecognizer(tapRecognizer)

    return headerCell
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 185;
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dismissNavigationDrawer()
    switch indexPath.row {
    case 0:
      if account == RoleType.Renter.rawValue {
        let bookingViewController = BookingViewController.instantiate()
        let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navigationController.viewControllers = [bookingViewController]
        self.present(navigationController, animated: true, completion: nil)
      } else {
        let jobViewController = JobViewController.instantiate()
        let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navigationController.viewControllers = [jobViewController]
        self.present(navigationController, animated: true, completion: nil)
      }
      break
    case 1:

      break
    case 2:
      if account == RoleType.Renter.rawValue {
        self.switchMenu()
      } else {
        let listingsViewController = ListingsViewController.instantiate()
        let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navigationController.viewControllers = [listingsViewController]
        self.present(navigationController, animated: true, completion: nil)
      }
      break
    case 3:
      if account == RoleType.Renter.rawValue {
        let faqViewController = FAQViewController.instantiate()
        let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navigationController.viewControllers = [faqViewController]
        self.present(navigationController, animated: true, completion: nil)
      } else {
        self.switchMenu()
      }
      break
    case 4:
      if account == RoleType.Renter.rawValue {
        let settingViewController = SettingViewController.instantiate()
        let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navigationController.viewControllers = [settingViewController]
        self.present(navigationController, animated: true, completion: nil)
      } else {
        let faqViewController = FAQViewController.instantiate()
        let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
        navigationController.viewControllers = [faqViewController]
        self.present(navigationController, animated: true, completion: nil)
      }
      break
    case 5:
      let settingViewController = SettingViewController.instantiate()
      let navigationController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
      navigationController.viewControllers = [settingViewController]
      self.present(navigationController, animated: true, completion: nil)
      break
    default:
      return
    }
  }
}

// MARK: - GMSMapView Delegates

extension ViewController: GMSMapViewDelegate {

  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    let mapMarker = marker as! MapMarker
    let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?.first as! MapInfoView
    infoWindow.layer.cornerRadius = 5
    infoWindow.frame = CGRect(x: infoWindow.frame.minX, y: infoWindow.frame.minY, width: self.view.frame.width - 40, height: infoWindow.frame.height)
    infoWindow.configure(viewModel: CarCellViewModel(car: mapMarker.car!))
    return infoWindow
  }

  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    let mapMarker = marker as! MapMarker
    guard let carDetailsViewController = UIStoryboard(name: "CarDetailsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "CarDetailsViewController") as? CarDetailsViewController else {
      return
    }
    carDetailsViewController.car = mapMarker.car
    carDetailsViewController.isDateSelected = isDateSelected
    carDetailsViewController.selectedStartDate = rentStartDate
    carDetailsViewController.selectedEndDate = rentEndDate
    carDetailsViewController.configure(viewModel: CarDetailsViewModel(car: mapMarker.car!))
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    self.navigationController?.pushViewController(carDetailsViewController, animated: true)
  }
}

// MARK: - Protocols

extension ViewController: CarTypeProtocol {
  func selectedCarType(carType: String) {
    self.carType = carType
  }

  func selectedCarModel(carModel: String) {
    self.carBrand = carModel
  }
}
