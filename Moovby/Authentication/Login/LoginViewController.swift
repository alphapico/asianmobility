//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift
import ObjectMapper
import PKHUD

class LoginViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var emailTextFieldContainer: UIView!
  @IBOutlet var emailTextField: UITextField!
  @IBOutlet var passwordTextFieldContainer: UIView!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var loginButton: UIButton!

  // MARK: - Properties

  let moovbyProvider = MoovbyProvider()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    emailTextFieldContainer.setupBorder()
    passwordTextFieldContainer.setupBorder()
    loginButton.layer.cornerRadius = 25
    loginButton.layer.borderColor = UIColor.white.cgColor
    loginButton.layer.borderWidth = 1

    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  // MARK: - Actions

  @IBAction func loginButtonDidTapped(_ sender: Any) {
    HUD.show(.progress)

    if isCumpolsoryFieldsFilled() {
      self.requestLogin(completion: { _ in
        HUD.hide(afterDelay: 1.0)
        self.pushHomeScreen()
      })
    } else {
      HUD.hide(afterDelay: 1.0)
      let alertController = UIAlertController(
        title: "Fail to Login",
        message: "Please enter your email and password",
        preferredStyle: UIAlertControllerStyle.alert
      )

      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }

  @IBAction func forgotButtonDidTapped(_ sender: Any) {
    let forgotPasswordViewController = ForgotPasswordViewController.instantiate()
    let navController = UINavigationController(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
    navController.viewControllers = [forgotPasswordViewController]
    self.present(navController, animated: true, completion: nil)
  }
}

extension LoginViewController {
  static func instantiate() -> LoginViewController {
    return UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
  }

  func pushHomeScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController") as! ViewController
    self.navigationController?.pushViewController(controller, animated: true)
  }

  func isCumpolsoryFieldsFilled() -> Bool {
    guard let email = emailTextField.text,
      let password = passwordTextField.text else {
        return false
    }

    if !email.isEmpty && !password.isEmpty {
      return true
    } else {
      return false
    }
  }

  func viewTapped(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }

  func requestLogin(completion: @escaping (_ success: Bool) -> Void) {
    guard let email = emailTextField.text, let password = passwordTextField.text else {
      return
    }
    guard let deviceUUID = UIDevice.current.identifierForVendor?.uuidString else { return }

    let deviceInfo: [String : Any] = [
      "device_identifier": deviceUUID,
      "device_information": UIDevice.current.systemVersion,
      "device_type": "iOS"
    ]

    let params: Parameters = [
      "email": email,
      "password": password,
      "device_info": deviceInfo
    ]

    Alamofire.request("\(moovbyProvider.baseURL)/signin", method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in

      if response.response?.statusCode == 200 {
        if let result = response.result.value {
          let JSON = result as! NSDictionary
          print("json: \(JSON)")
        }

        let loginResult = Mapper<UserLoginResult>().map(JSON: response.result.value as! [String : Any], toObject: UserLoginResult())

        let realm = try! Realm()

        try! realm.write {
          realm.add(loginResult, update: true)
        }

        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isLogin")

        completion(true)
      } else {
        HUD.hide()
        let alertController = UIAlertController(
          title: "Fail to Login",
          message: "Sorry, We don't recognize your email or password",
          preferredStyle: UIAlertControllerStyle.alert
        )

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }
}
