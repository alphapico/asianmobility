//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import ObjectMapper
import RealmSwift
import BWWalkthrough
import Firebase

class InitialViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var registerButton: UIButton!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var facebookLoginButton: UIButton!

  // MARK: - Properties

  let moovbyProvider = MoovbyProvider()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    let userDefaults = UserDefaults.standard

    if !userDefaults.bool(forKey: "walkthroughPresented") {

      showWalkthrough()

      userDefaults.set(true, forKey: "walkthroughPresented")
      userDefaults.synchronize()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    registerButton.layer.cornerRadius = registerButton.frame.size.height/2
    loginButton.layer.cornerRadius = loginButton.frame.size.height/2
    loginButton.layer.borderColor = UIColor.white.cgColor
    loginButton.layer.borderWidth = 1
    facebookLoginButton.layer.cornerRadius = facebookLoginButton.frame.size.height/2
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    title = ""
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }

  // MARK: - Actions

  @IBAction func registerButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("onboarding_tap_register_button", parameters: nil)

    let registerViewController = RegisterViewController.instantiate()
    self.navigationController?.pushViewController(registerViewController, animated: true)
  }

  @IBAction func loginButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("onboarding_tap_login_button", parameters: nil)

    let loginViewController = LoginViewController.instantiate()
    self.navigationController?.pushViewController(loginViewController, animated: true)
  }

  @IBAction func facebookLoginButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("onboarding_tap_facebook_button", parameters: nil)

    let permissions = ["public_profile", "email", "user_friends"]
    let login: FBSDKLoginManager = FBSDKLoginManager()
    login.logIn(withReadPermissions: permissions, from: self, handler: { result, error in
      if error != nil {
        print("Process error")
      } else if (result?.isCancelled)! {
        print("Cancelled")
      } else if (result?.grantedPermissions.contains("email"))! {
        print("Logged in")
        self.getUserFacebookInfo()
      }
    })
  }
}

// MARK: - Methods

extension InitialViewController {
  func getUserFacebookInfo() {
    FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) in
      if error != nil {
        print("failed to start graph request: \(error)")
        return
      }
      let data = result as! [String: Any]

      self.requestSignInWithFacebook(email: data["email"] as! String, uid: data["id"] as! String, completion: { (success) in
        if success {
          let userDefaults = UserDefaults.standard
          userDefaults.set(true, forKey: "isLogin")
          self.presentHomeScreen()
        }
      })

      print(data["id"] as! String, data["email"] as! String, data["name"] as! String)
    })
  }

  func requestSignInWithFacebook(email: String, uid: String, completion: @escaping (_ success: Bool) -> Void) {
    guard let deviceUUID = UIDevice.current.identifierForVendor?.uuidString else { return }

    let deviceInfo : [String : Any] = [
      "device_identifier": deviceUUID,
      "device_information": UIDevice.current.systemVersion,
      "device_type": "iOS"
    ]

    let params: Parameters = [
      "email": email,
      "uid": uid,
      "device_info": deviceInfo
    ]

    Alamofire.request("\(moovbyProvider.baseURL)/signin/facebook", method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in

      if response.response?.statusCode == 200 {
        let loginResult = Mapper<UserLoginResult>().map(JSON: response.result.value as! [String : Any], toObject: UserLoginResult())

        let realm = try! Realm()
        try! realm.write {
          realm.add(loginResult, update: true)
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isLogin")

        completion(true)
      } else {
        let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)

        completion(false)
      }
    }
  }

  func showWalkthrough() {
    // Get view controllers and build the walkthrough
    let stb = UIStoryboard(name: "PageControllerStoryboard", bundle: nil)
    let walkthrough = stb.instantiateViewController(withIdentifier: "container") as! BWWalkthroughViewController
    let page_zero = stb.instantiateViewController(withIdentifier: "first")
    let page_one = stb.instantiateViewController(withIdentifier: "second")
    let page_two = stb.instantiateViewController(withIdentifier: "third")
    let page_three = stb.instantiateViewController(withIdentifier: "fourth")

    // Attach the pages to the master
    walkthrough.delegate = self
    walkthrough.add(viewController:page_one)
    walkthrough.add(viewController:page_two)
    walkthrough.add(viewController:page_three)
    walkthrough.add(viewController:page_zero)

    self.present(walkthrough, animated: true, completion: nil)
  }

  func presentHomeScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController")
    self.navigationController?.pushViewController(controller, animated: true)
  }
}

// MARK: - BWWalkthroughViewController Delegates

extension InitialViewController: BWWalkthroughViewControllerDelegate {
  func walkthroughPageDidChange(_ pageNumber: Int) {
    print("Current Page \(pageNumber)")
  }

  func walkthroughCloseButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }
}
