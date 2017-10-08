//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift
import ObjectMapper
import PKHUD
import SafariServices
import Firebase

class RegisterViewController: UIViewController, SFSafariViewControllerDelegate {

  // MARK: - Outlets

  @IBOutlet var emailTextFieldContainer: UIView!
  @IBOutlet var emailTextField: UITextField!
  @IBOutlet var passwordTextFieldContainer: UIView!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var tncAgreementButton: CheckBox!

  // MARK: - Properties

  let moovbyProvider = MoovbyProvider()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Register"
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    emailTextFieldContainer.setupBorder()
    passwordTextFieldContainer.setupBorder()

    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  static func instantiate() -> RegisterViewController {
    return UIStoryboard(name: "RegistrationStoryboard", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
  }

  @IBAction func tncAgreementButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("register_tap_checkbox_button", parameters: nil)

    if tncAgreementButton.isChecked == false {
      tncAgreementButton.setImage(UIImage(named: "checked"), for: .normal)
    } else {
      tncAgreementButton.setImage(UIImage(named: "unchecked"), for: .normal)
    }
  }
  
  @IBAction func registerButtonDidTapped(_ sender: Any) {
    HUD.show(.progress)

    guard let email = emailTextField.text,
      let password = passwordTextField.text else {
        return
    }

    Analytics.logEvent("register_tap_register_button", parameters: nil)
    
    if isCumpolsoryFieldsFilled() {
      let params: Parameters = [
        "email": email,
        "password": password
      ]

      Alamofire.request("\(moovbyProvider.baseURL)/signup", method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
        switch response.result {
        case .success:
          let signUpResult = Mapper<UserLoginResult>().map(JSON: response.result.value as! [String : Any], toObject: UserLoginResult())
          
          let realm = try! Realm()
          try! realm.write {
            realm.add(signUpResult, update: true)
          }
          
          let userDefaults = UserDefaults.standard
          userDefaults.set(true, forKey: "isLogin")

          HUD.hide()

          self.presentProfileCreationViewController()
          break
        default:
          HUD.hide()
          let alertController = UIAlertController(title: "Oops!", message: "Something went wrong, please try again later.", preferredStyle: UIAlertControllerStyle.alert)
          
          let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
          {
            (result : UIAlertAction) -> Void in
          }
          alertController.addAction(okAction)
          self.present(alertController, animated: true, completion: nil)
        }
      }
    } else {
      HUD.hide()

      let alertController = UIAlertController(title: "Fail to Register", message: "Please fill in all the fields and make sure you are aggree to the Terms and Condition. Thank you.", preferredStyle: UIAlertControllerStyle.alert)

      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
      {
        (result : UIAlertAction) -> Void in
      }
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }

  @IBAction func goToLoginButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("register_tap_login_button", parameters: nil)

    let loginViewController = LoginViewController.instantiate()
    self.navigationController?.pushViewController(loginViewController, animated: true)
  }

  // MARK: - Private functions
  func isCumpolsoryFieldsFilled() -> Bool {
    guard let email = emailTextField.text,
      let password = passwordTextField.text else {
        return false
    }

    if !email.isEmpty && !password.isEmpty && password.characters.count > 7 && tncAgreementButton.isChecked {
      return true
    } else {
      return false
    }
  }

  @IBAction func tncButtonTapped(_ sender: Any) {
    Analytics.logEvent("register_tap_tnc_button", parameters: nil)

    if let url = URL(string: "https://moovby.com/pages/privacy_policy") {
      let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
      vc.delegate = self
      present(vc, animated: true, completion: nil)
    }
  }

  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
  }

  func presentProfileCreationViewController() {
    let profileViewController = NameViewController.instantiate()
    self.navigationController?.pushViewController(profileViewController, animated: true)
  }

  func viewTapped(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
}
