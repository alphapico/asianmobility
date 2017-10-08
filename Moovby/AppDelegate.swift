//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RealmSwift
import Alamofire
import ObjectMapper
import GooglePlaces
import FBSDKCoreKit
import Fabric
import Crashlytics
import Firebase
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  // MARK: - Delegates

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    configureRealm()
    configureFirebase()
    configureFabric()
    configureGoogleMapServices()
    configureKeyboardManager()
    configureInitialRootController()

    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    FBSDKAppEvents.activateApp()
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance()
                            .application(application,
                                        open: url,
                                        sourceApplication: sourceApplication,
                                        annotation: annotation)
    return facebookDidHandle
  }
}

// MARK: - Configurations

extension AppDelegate {
  fileprivate func configureInitialRootController() {
    let userDefaults = Foundation.UserDefaults.standard
    let isUserLogin  = userDefaults.bool(forKey: "isLogin")

    if isUserLogin == true {
      // display home screen
      let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let initialViewController = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController") as! ViewController
      let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
      navigationController.viewControllers = [initialViewController]
      self.window?.rootViewController = navigationController
    } else {
      // User is not login so display initial screen
      let storyboard: UIStoryboard = UIStoryboard(name: "AuthenticationStoryboard", bundle: nil)
      let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "authenticationScreen") as UIViewController
      let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
      navigationController.viewControllers = [initialViewController]
      self.window?.rootViewController = navigationController
    }
  }

  fileprivate func configureGoogleMapServices() {
    GMSServices.provideAPIKey("AIzaSyDo7Kl8yV0H442tyuwdGuKhEX0i2EJS-Ps")
    GMSPlacesClient.provideAPIKey("AIzaSyDo7Kl8yV0H442tyuwdGuKhEX0i2EJS-Ps")
  }

  fileprivate func configureFabric() {
    Fabric.with([Crashlytics.self])
  }

  fileprivate func configureRealm() {
    let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
      if oldSchemaVersion < 1 {
        migration.enumerateObjects(ofType: UserProfile.className()) { oldObject, newObject in

        }
      }
      if oldSchemaVersion < 2 {}
    }

    Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 2, migrationBlock: migrationBlock)
    if let realmFile = Realm.Configuration.defaultConfiguration.fileURL {
      debugPrint("Realm File URL: \(realmFile)")
    }
  }

  fileprivate func configureFirebase() {
    guard let filename = Bundle.main.infoDictionary!["Google Services Filename"] as? String else {
      fatalError("Cannot find plist configuration for Google Services")
    }
    guard let configurations = Bundle.main.path(forResource: filename, ofType: "plist") else {
      fatalError("Cannot find Firebase configuration")
    }
    guard let options = FirebaseOptions(contentsOfFile: configurations) else {
      fatalError("Invalid Google Service configuration file")
    }
    FirebaseApp.configure(options: options)
  }
  
  fileprivate func configureKeyboardManager() {
    IQKeyboardManager.shared().isEnabled = true
  }
}
