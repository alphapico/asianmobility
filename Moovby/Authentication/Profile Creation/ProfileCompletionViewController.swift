//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import ObjectMapper
import PKHUD
import Firebase

class ProfileCompletionViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var startButton: UIButton!

  // MARK: - Properties

  let repo = UserProfileRepository().profile().first
  var role: Int = 1
  let moovbyProvider = MoovbyProvider()

  // MARK: - Lifecyle

  override func viewDidLoad() {
    super.viewDidLoad()
    startButton.layer.cornerRadius = 25
  }

  // MARK: - Actions

  @IBAction func startButtonDidTapped(_ sender: Any) {
    HUD.show(.progress)
    postUserProfileRequest { (success) in
      if success {
        HUD.hide()
        self.pushHomeScreen()
      }
    }
  }
}

// MARK: - Methods

extension ProfileCompletionViewController {
  func postUserProfileRequest(completion: @escaping (_ success: Bool) -> Void) {
    // renter = 1, owner = 2, both = 3
    if repo?.isRenter == true && repo?.isCarOwner == true {
      role = 3
    } else if repo?.isCarOwner == true && repo?.isRenter == false {
      role = 2
    } else if repo?.isRenter == true && repo?.isCarOwner == false {
      role = 1
    }

    guard let phoneNumber = self.repo?.phoneNumber,
      let firstName = self.repo?.firstName,
      let lastName = self.repo?.lastName,
      let icData = self.repo?.icImage,
      let licenseData = self.repo?.drivingLicenseImage else {
        return
    }

    let params: Parameters = [
      "phone": phoneNumber,
      "first_name": firstName,
      "last_name": lastName,
      "role": role,
      "ic": "data:image/jpeg;base64,\(icData)",
      "driving_license": "data:image/jpeg;base64,\(licenseData)"
    ]

    Alamofire.request("\(moovbyProvider.baseURL)/profiles", method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { response in
      switch response.result {
      case .success:
        let realm = try! Realm()
        let user = realm.objects(UserProfile.self).first
        try! realm.write {
          user?.isRequested = true
        }

        self.dismiss(animated: true, completion: {
          Analytics.logEvent("profile_complete_tap_next_button", parameters: nil)
        })

        completion(true)
        break
      default:
        self.presentAlertController()
      }
    }
  }

  func pushHomeScreen() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController") as! ViewController
    self.navigationController?.pushViewController(controller, animated: true)
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
}
