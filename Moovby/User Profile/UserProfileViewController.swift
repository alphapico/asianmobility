//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift
import PKHUD

class UserProfileViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet weak var firstNameContainer: UIView!
  @IBOutlet weak var lastNameContainer: UIView!
  @IBOutlet weak var emailContainer: UIView!
  @IBOutlet weak var phoneNumberContainer: UIView!
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var scrollView: UIScrollView!
  let viewModel = UserProfileViewModel()
  let moovbyProvider = MoovbyProvider()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    firstNameContainer.setupBorder()
    lastNameContainer.setupBorder()
    emailContainer.setupBorder()
    phoneNumberContainer.setupBorder()
    configure()
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "Edit Profile"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  static func instantiate() -> UserProfileViewController {
    return UIStoryboard(name: "UserProfileStoryboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
  }
  
  func configure() {
    firstNameTextField.text = viewModel.firstName()
    lastNameTextField.text = viewModel.lastName()
    emailTextField.text = viewModel.email()
    phoneNumberTextField.text = viewModel.phoneNumber()
  }
  
  @IBAction func saveButtonDidTapped(_ sender: Any) {
    // call api patch user profile
    HUD.show(.progress)
    let userId = viewModel.userRepo?.id
    let url = "\(moovbyProvider.baseURL)/users/\(String(describing: userId))"
    
    guard let firstName = firstNameTextField.text,
      let lastName = lastNameTextField.text,
      let phoneNumber = phoneNumberTextField.text,
      let email = emailTextField.text else {
        return
    }
    
    let userProfile : [String : Any] = [
      "first_name": firstName,
      "last_name": lastName,
      "phone": phoneNumber
    ]
    
    let params: Parameters = [
      "email": email,
      "profile": userProfile
    ]
    
    Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { (response) in
      if response.response?.statusCode == 200 {
        // update local db
        let userRepo = UserLoginRepository().users().first
        let userProfileRepo = UserProfileRepository().profile().first
        
        let realm = try! Realm()
        try! realm.write {
          userRepo?.email = email
          userProfileRepo?.firstName = firstName
          userProfileRepo?.lastName = lastName
          userProfileRepo?.phoneNumber = phoneNumber
        }
        
        HUD.hide()
        self.dismiss(animated: true, completion: nil)
      } else {
        HUD.hide()
        let alertController = UIAlertController(title: "Oops!", message: "Fail to update profile. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
      }
    }
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func viewTapped(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func keyboardWillShow(notification:NSNotification) {
    var userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    
    var contentInset:UIEdgeInsets = scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height
    scrollView.contentInset = contentInset
  }
  
  func keyboardWillHide(notification:NSNotification) {
    var contentInset:UIEdgeInsets = scrollView.contentInset
    contentInset.top = 65.0
    scrollView.contentInset = contentInset
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
}
