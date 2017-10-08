//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class IdentityViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var icImageView: UIImageView!
  @IBOutlet var drivingLicenseImageView: UIImageView!
  @IBOutlet var nextButton: UIButton! {
    didSet {
      nextButton.layer.cornerRadius = nextButton.frame.size.height / 2
    }
  }
  @IBOutlet var sampleimage: UIImageView!

  // MARK: - Properties

  fileprivate var isICPhoto: Bool = false
  fileprivate var isPhotoTaken: Bool = false
  fileprivate var isLicenseTaken: Bool = false
  let imagePicker = UIImagePickerController()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    title = "Upload Documents"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    icImageView.setupBorder()
    drivingLicenseImageView.setupBorder()

    imagePicker.delegate = self
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = false

    icImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectICImageView)))
    drivingLicenseImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectDrivingLicenseImageView)))
  }

  override func viewWillDisappear(_ animated: Bool) {
    title = ""
  }

  // MARK: - Actions

  @IBAction func nextButtonDidTapped(_ sender: Any) {
  }

  // MARK: - Segues

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "ConfirmationId" {
      if isPhotoTaken && isLicenseTaken {
        let realm = try! Realm()
        let user = realm.objects(UserProfile.self).first
        try! realm.write {
          user?.icImage = (icImageView.image?.base64(format: .png))!
          user?.drivingLicenseImage = (drivingLicenseImageView.image?.base64(format: .png))!
        }

        Analytics.logEvent("profile_document_tap_next_button", parameters: nil)

        return true
      } else {
        displayAlert()
        return false
      }
    }
    return true
  }
}

// MARK: - Methods

extension IdentityViewController {
  @objc fileprivate func handleSelectICImageView() {
    isICPhoto = true
    takePhotoFromCamera()
  }

  @objc fileprivate func handleSelectDrivingLicenseImageView() {
    isICPhoto = false
    takePhotoFromCamera()
  }

  fileprivate func takePhotoFromCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      self.present(imagePicker, animated: true, completion: nil)
    }
  }

  fileprivate func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
  }

  fileprivate func displayAlert() {
    let alertController = UIAlertController(
      title: "",
      message: "Please provide picture of your IC/Passport and driving license. Thank you.",
      preferredStyle: UIAlertControllerStyle.alert
    )

    let okAction = UIAlertAction(
      title: "OK",
      style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
}

// MARK: - UIImage Picker Controller Delegate

extension IdentityViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      if isICPhoto {
        icImageView.contentMode = .scaleAspectFit
        icImageView.image = self.resizeImage(image: pickedImage, newWidth: 200)
        isPhotoTaken = true
      } else {
        drivingLicenseImageView.contentMode = .scaleAspectFit
        drivingLicenseImageView.image = self.resizeImage(image: pickedImage, newWidth: 200)
        isLicenseTaken = true
      }
    }
    picker.dismiss(animated: true, completion: nil)
  }
}

extension IdentityViewController: UINavigationControllerDelegate {}
