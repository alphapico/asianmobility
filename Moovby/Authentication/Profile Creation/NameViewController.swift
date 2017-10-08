//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class NameViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var firstNameContainerView: UIView!
  @IBOutlet var firstNameTextField: UITextField!
  @IBOutlet var lastNameContainerView: UIView!
  @IBOutlet var lastNameTextField: UITextField!
  @IBOutlet var nextButton: UIButton!

  // MARK: - Lifecycles

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Welcome to Moovby"
    self.navigationItem.setHidesBackButton(true, animated: true)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    firstNameContainerView.setupBorder()
    lastNameContainerView.setupBorder()
    nextButton.layer.cornerRadius = 25

    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
  }

  override func viewWillDisappear(_ animated: Bool) {
    title = ""
  }

  // MARK: - Actions

  @IBAction func nextButtonDidTapped(_ sender: Any) {
  }

  @IBAction func SkipButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("profile_name_tap_skip_button", parameters: nil)
    presentHomeScreen()
  }

  // MARK: - Segues

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "setPhoneNumber" {
      guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text else {
        return false
      }

      if firstName.isEmpty || lastName.isEmpty {
        displayAlert()
        return false
      } else {
        let realm = try! Realm()
        
        try! realm.write() {
          realm.create(UserProfile.self, value: ["firstName": firstName, "lastName": lastName], update: true)
        }

        Analytics.logEvent("profile_name_tap_next_button", parameters: nil)
        
        return true
      }
    }
    return true
  }
}

// MARK: - Methods

extension NameViewController {
  static func instantiate() -> NameViewController {
    return UIStoryboard(name: "ProfileCreationStoryboard", bundle: nil).instantiateViewController(withIdentifier: "NameViewController") as! NameViewController
  }

  func presentHomeScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController") as! ViewController
    self.navigationController?.pushViewController(controller, animated: true)
  }

  func cancelView() {
    self.dismiss(animated: true, completion: nil)
  }

  func displayAlert() {
    let alertController = UIAlertController(title: "", message: "Please fill in all the fields. Thank you.", preferredStyle: UIAlertControllerStyle.alert)

    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  func viewTapped(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
}
