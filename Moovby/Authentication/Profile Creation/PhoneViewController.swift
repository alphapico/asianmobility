//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class PhoneViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var phoneNumberContainer: UIView!
  @IBOutlet var phoneNumberTextField: UITextField!
  @IBOutlet var nextButton: UIButton! {
    didSet {
      nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }
  }

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    title = "Set phone number"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    phoneNumberContainer.setupBorder()

    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
  }

  override func viewWillDisappear(_ animated: Bool) {
    title = ""
  }

  // MARK: - Actions

  @IBAction func nextButtonDidTapped(_ sender: Any) {
  }

  // MARK: - Segues

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "chooseAccountType" {
      guard let phoneNumber = phoneNumberTextField.text else { return false }
      
      if phoneNumber.isEmpty {
        displayAlert()
        return false
      } else {
        let realm = try! Realm()
        let user = realm.objects(UserProfile.self).first
        try! realm.write {
          user?.phoneNumber = phoneNumber
        }

        Analytics.logEvent("profile_phone_tap_next_button", parameters: nil)

        return true
      }
      
    }
    return true
  }

}

// MARK: - Methods

extension PhoneViewController {
  fileprivate func displayAlert() {
    let alertController = UIAlertController(
      title: "",
      message: "Please provide your phone number. Thank you.",
      preferredStyle: UIAlertControllerStyle.alert
    )

    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  func viewTapped(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
}
