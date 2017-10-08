//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class AccountTypeViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var carOwnerViewContainer: UIView!
  @IBOutlet var renterViewContainer: UIView!
  @IBOutlet var nextButton: UIButton! {
    didSet {
      nextButton.layer.cornerRadius = nextButton.frame.size.height / 2
    }
  }
  @IBOutlet var renterImageView: UIImageView!
  @IBOutlet var carOwnerImageView: UIImageView!
  @IBOutlet var selectCarOwnerButton: CheckBox!
  @IBOutlet var selectRenterButton: CheckBox!
  @IBOutlet var ownerTitleLabel: UILabel!
  @IBOutlet var ownerDescriptionLabel: UILabel!
  @IBOutlet var renterTitleLabel: UILabel!
  @IBOutlet var renterDescriptionLabel: UILabel!

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    title = "Choose account type"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    carOwnerViewContainer.setupBorder()
    renterViewContainer.setupBorder()
  }

  override func viewWillDisappear(_ animated: Bool) {
    title = ""
  }

  // MARK: - Actions
  
  @IBAction func carOwnerButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("profile_account_tap_owner_button", parameters: nil)

    if !selectCarOwnerButton.isChecked {
      selectedView(selectedView: carOwnerViewContainer,
                   selectedImageView: carOwnerImageView,
                   selectedTitleLabel: ownerTitleLabel,
                   selectedDescriptionLabel: ownerDescriptionLabel)
    } else {
      deselectView(deselectedView: carOwnerViewContainer,
                   deselectedImageView: carOwnerImageView,
                   deselectedTitleLabel: ownerTitleLabel,
                   deselectedDescriptionLabel: ownerDescriptionLabel)
    }
  }
  
  @IBAction func carRenterButtonDidTapped(_ sender: Any) {
    Analytics.logEvent("profile_account_tap_renter_button", parameters: nil)
    if !selectRenterButton.isChecked {
      selectedView(selectedView: renterViewContainer,
                   selectedImageView: renterImageView,
                   selectedTitleLabel: renterTitleLabel,
                   selectedDescriptionLabel: renterDescriptionLabel)
    } else {
      deselectView(deselectedView: renterViewContainer,
                   deselectedImageView: renterImageView,
                   deselectedTitleLabel: renterTitleLabel,
                   deselectedDescriptionLabel: renterDescriptionLabel)
    }
  }

  @IBAction func nextButtonDidTapped(_ sender: Any) {
  }

  // MARK: - Segues

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "identityImage" {
      if !selectCarOwnerButton.isChecked && !selectRenterButton.isChecked {
        displayAlert()
        return false
      } else {
        let realm = try! Realm()
        let user = realm.objects(UserProfile.self).first
        try! realm.write {
          user?.isCarOwner = self.selectCarOwnerButton.isChecked
          user?.isRenter = self.selectRenterButton.isChecked
        }

        Analytics.logEvent("profile_account_tap_next_button", parameters: nil)

        return true
      }
    }
    return true
  }
}

// MARK: - Methods

extension AccountTypeViewController {
  fileprivate func selectedView(selectedView: UIView, selectedImageView: UIImageView,
                                selectedTitleLabel: UILabel, selectedDescriptionLabel: UILabel) {
    selectedView.backgroundColor = UIColor.white
    selectedImageView.image = UIImage(named: "choice")
    selectedTitleLabel.textColor = UIColor.moovbyGreen
    selectedDescriptionLabel.textColor = UIColor.moovbyGreen
  }

  fileprivate func deselectView(deselectedView: UIView, deselectedImageView: UIImageView,
                                deselectedTitleLabel: UILabel, deselectedDescriptionLabel: UILabel) {
    deselectedView.backgroundColor = UIColor.clear
    deselectedImageView.image = nil
    deselectedTitleLabel.textColor = UIColor.white
    deselectedDescriptionLabel.textColor = UIColor.white
  }

  fileprivate func displayAlert() {
    let alertController = UIAlertController(
      title: "",
      message: "Please choose at least one account type. Thank you.",
      preferredStyle: UIAlertControllerStyle.alert
    )

    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

}
