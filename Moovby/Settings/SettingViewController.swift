//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ObjectMapper
import FBSDKLoginKit

class SettingViewController: UIViewController {
  
  @IBOutlet var userImageView: UIImageView!
  @IBOutlet var userNameLabel: UILabel!
  @IBOutlet var userPhoneNumberLabel: UILabel!
  @IBOutlet var userEmailLabel: UILabel!
  @IBOutlet var logoutButton: UIButton!
  @IBOutlet var appVersionLabel: UILabel!
  let repo = RealmRepository()
  let realm = try! Realm()
  let userRepo = UserLoginRepository().users().first
  let userProfileRepo = UserProfileRepository().profile().first
  
  override func viewDidLoad() {
    super.viewDidLoad()
    logoutButton.layer.cornerRadius = 25
    
    userImageView.image = UIImage(named: "mapInfoViewPlaceholder")
    let firstName = userProfileRepo?.firstName
    let lastName = userProfileRepo?.lastName
    
    if userProfileRepo == nil {
      userNameLabel.text = ""
    } else {
      userNameLabel.text = "\(firstName!) \(lastName!)"
    }
    userPhoneNumberLabel.text = userProfileRepo?.phoneNumber
    userEmailLabel.text = userRepo?.email

    let appInfo = Bundle.main.infoDictionary as! Dictionary<String,AnyObject>
    let shortVersionString = appInfo["CFBundleShortVersionString"] as! String
    let bundleVersion = appInfo["CFBundleVersion"] as! String
    
    self.appVersionLabel.text = "Version \(shortVersionString).\(bundleVersion)"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "Settings"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  static func instantiate() -> SettingViewController {
    return UIStoryboard(name: "SettingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingViewController
  }

  @IBAction func logoutButtonDidTapped(_ sender: Any) {
    let bookings = RealmRepository().objects(type: Bookings.self)
    let userBookingResult = RealmRepository().objects(type: BookingResult.self)
    let userProfiles = RealmRepository().objects(type: UserProfile.self)
    let userProfileResult = RealmRepository().objects(type: UserProfileResult.self)
    let users = RealmRepository().objects(type: User.self)
    let userLoginResult = RealmRepository().objects(type: UserLoginResult.self)
    
    
    try! realm.write {
      for booking in bookings {
        RealmRepository().deleteObject(object: booking)
      }
      
      for bookingResult in userBookingResult {
        RealmRepository().deleteObject(object: bookingResult)
      }
      
      for profile in userProfiles {
        RealmRepository().deleteObject(object: profile)
      }
      
      for profileResult in userProfileResult {
        RealmRepository().deleteObject(object: profileResult)
      }
      
      for user in users {
          RealmRepository().deleteObject(object: user)
      }
      for loginResult in userLoginResult {
        RealmRepository().deleteObject(object: loginResult)
      }
    }
    
    if FBSDKAccessToken.current() != nil {
      let manager = FBSDKLoginManager()
      manager.logOut()
      
      FBSDKAccessToken.setCurrent(nil)
      FBSDKProfile.setCurrent(nil)
    }
    
    let userDefaults = UserDefaults.standard
    userDefaults.set(false, forKey: "isLogin")
        
    let storyboard: UIStoryboard = UIStoryboard(name: "AuthenticationStoryboard", bundle: nil)
    let navigationController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
    let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "authenticationScreen") as UIViewController
    navigationController.viewControllers = [initialViewController]
    UIApplication.shared.keyWindow?.rootViewController = navigationController
    
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
