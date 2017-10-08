//
//  HostController.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 27/09/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class HostController: UIViewController {

  // MARK: - Properties

  var account: Int = Role.sharedInstance.userRole
  let tableView: UITableView = {
    let tv = UITableView(frame: .zero)
    return tv
  }()
  let navigationDrawerRearView = UIView()
  let moovbyProvider = MoovbyProvider()

  var notices: [Notice] = []

  @IBOutlet weak var listView: UITableView!

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  override func viewDidLoad() {
    title = "Inbox"

    super.viewDidLoad()
    configureUI()
    configureNavigationDrawer()
    requestInboxNotifications()
    configureList()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = true
  }

  func requestInboxNotifications() {

    let url = "\(moovbyProvider.baseURL)/notices"
    let headers = self.moovbyProvider.headers()

    Alamofire.request(url, headers: headers).responseJSON { response in
      guard let statusCode = response.response?.statusCode else { return }
      if statusCode == 200 {
        if let json = response.result.value as? [String: Any] {
          guard let result = Mapper<Notice>().mapArray(JSONArray: json["notices"] as! [[String: Any]]) else { return }

          self.notices = result
          self.listView.reloadData()
        }
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
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController") as UIViewController
    self.navigationController?.viewControllers = [controller]
  }

  private func configureUI() {
    let menuButton = UIBarButtonItem(
      image: UIImage(named: "hamburger-menu"),
      style: .done,
      target: self,
      action: #selector(navigationDrawerButtonDidTapped(_:)))
    menuButton.tintColor = UIColor.moovbyGreen

    self.navigationItem.leftBarButtonItem = menuButton
    self.automaticallyAdjustsScrollViewInsets = false
  }

  private func configureList() {
    listView.register(UINib(nibName: "NotificationCell", bundle: nil),
                      forCellReuseIdentifier: "NotificationCell")

    self.listView.delegate = self
    self.listView.dataSource = self
    self.listView.rowHeight = UITableViewAutomaticDimension
    self.listView.estimatedRowHeight = 72
    self.listView.tableHeaderView = UIView(frame: CGRect.zero)
  }

  private func configureNavigationDrawer() {
    tableView.register(UINib(nibName: "NavigationDrawerCell", bundle: nil), forCellReuseIdentifier: "NavigationDrawerCell")
    tableView.register(UINib(nibName: "CustomHeaderCell", bundle: nil), forCellReuseIdentifier: "CustomHeaderCell")

    tableView.delegate = self
    tableView.dataSource = self

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200
    tableView.tableFooterView = UIView()
    tableView.reloadData()
  }

  // MARK: - Actions

  func navigationDrawerButtonDidTapped(_ sender: Any) {
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
}

// MARK: - UITableView Data Source

extension HostController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      return account == RoleType.Renter.rawValue ? 5 : 6
    }
    if tableView == self.listView {
      return notices.count
    }
    return 0
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if tableView == self.tableView {
      let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationDrawerCell",
                                               for: indexPath) as! NavigationDrawerCell
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
    } else if tableView == self.listView {

      let notice = notices[indexPath.row]

      let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell",
                                               for: indexPath) as! NotificationCell
      cell.configure(notice: notice)

      return cell
    } else {
      // Default
      let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationDrawerCell",
                                               for: indexPath) as! NavigationDrawerCell
      return cell
    }
  }
}

// MARK: - UITableView Delegates

extension HostController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerCell: CustomHeaderCell = tableView.dequeueReusableCell(withIdentifier: "CustomHeaderCell") as! CustomHeaderCell

    if tableView == self.tableView {
      let userRepo = UserLoginRepository().users().first
      let userProfileRepo = UserProfileRepository().profile().first

      let email = userRepo?.email
      let firstName = userProfileRepo?.firstName
      let lastName = userProfileRepo?.lastName

      if userProfileRepo == nil {
        headerCell.userNameLabel.text = "\(email!)"
      } else {
        headerCell.userNameLabel.text = "\(firstName!) \(lastName!)"
      }
      //    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentUserProfileViewController))
      //    headerCell.addGestureRecognizer(tapRecognizer)

      return headerCell
    }
    return nil
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if tableView == self.tableView {
      return 185
    } else {
      return 0
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if tableView == self.tableView {
      return 56
    } else {
      return UITableViewAutomaticDimension
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == self.tableView {
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
}
