//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import PKHUD

class DocumentsVerificationViewController: UIViewController, UINavigationControllerDelegate {

  // MARK: - Outlets

  @IBOutlet var roadTaxImageView: UIImageView! {
    didSet {
      roadTaxImageView.layer.cornerRadius = 5
      roadTaxImageView.layer.borderWidth = 1
      roadTaxImageView.layer.borderColor = UIColor.moovbyGreen.cgColor
    }
  }
  @IBOutlet var insuranceCovernoteImageView: UIImageView! {
    didSet {
      insuranceCovernoteImageView.layer.cornerRadius = 5
      insuranceCovernoteImageView.layer.borderWidth = 1
      insuranceCovernoteImageView.layer.borderColor = UIColor.moovbyGreen.cgColor
    }
  }
  @IBOutlet var submitButton: UIButton! {
    didSet {
      submitButton.layer.cornerRadius = submitButton.frame.size.height / 2
    }
  }

  // MARK: - Properties

  fileprivate var isRoadTaxPhoto: Bool = false
  fileprivate var isRoadTaxTaken: Bool = false
  fileprivate var isInsuranceCovernoteTaken: Bool = false
  let moovbyProvider = MoovbyProvider()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    roadTaxImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectICImageView)))
    insuranceCovernoteImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectDrivingLicenseImageView)))
  }

  // MARK: - Methods

  func handleSelectICImageView() {
    isRoadTaxPhoto = true
    takePhotoFromCamera()
  }

  func takePhotoFromCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .camera
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true, completion: nil)
    }
  }

  func handleSelectDrivingLicenseImageView() {
    isRoadTaxPhoto = false
    takePhotoFromCamera()
  }

  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
  }

  func displayAlert() {
    let alertController = UIAlertController(
      title: "",
      message: "Please provide picture of your Roadtax and Insurance Covernote. Thank you.",
      preferredStyle: .alert
    )

    let okAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  func createVehicle() {
    HUD.show(.progress)
    let user = UserLoginRepository().users().first
    guard let userId = user?.id else { return }
    let url = "\(moovbyProvider.baseURL)/users/\(String(describing: userId))/vehicles"

    let params: Parameters = [
      "vehicle_detail_id":10,
      "year":2014,
      "transmission":"Auto",
      "color":"Green",
      "plate_num":"WUV 9183",
      "is_available":true,
      "description":"It is very comfortable to ride in it. I think people will love the ride experience in a this car. Great gas saver especially when you have to do a lot of driving. Wish you enjoy the trip. No smoking or pets please! Safe drive.",
      "roadtax":"",
      "insurance_covernote":"",
      "address":"Bukit Kerinchi, Kuala Lumpur, Federal Territory of Kuala Lumpur",
      "latitude":3.100241,
      "longitude":101.6642803
    ]

    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: moovbyProvider.headers()).responseJSON { (response) in
      if response.response?.statusCode == 200 {
        // update local OwnerVehicle db

        let realm = try! Realm()
        try! realm.write {

        }

        HUD.hide()
        self.dismiss(animated: true, completion: nil)
      } else {
        HUD.hide()
        let alertController = UIAlertController(title: "Oops!", message: "Fail to create vehicle. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        {
          (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
      }
    }
  }

  // MARK: - Actions

  @IBAction func submitButtonDidTapped(_ sender: Any) {
    if isRoadTaxTaken && isInsuranceCovernoteTaken {
      let realm = try! Realm()
      let vehicle = realm.objects(OwnerVehicle.self).first
      try! realm.write {
        vehicle?.roadTax = (roadTaxImageView.image?.base64(format: .png))!
        vehicle?.insuranceCoverNote = (insuranceCovernoteImageView.image?.base64(format: .png))!
      }
      
      self.createVehicle()
    } else {
      displayAlert()
    }
  }
}

// MARK: - UIIMagePickerController Delegates

extension DocumentsVerificationViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      if isRoadTaxPhoto {
        roadTaxImageView.contentMode = .scaleAspectFit
        roadTaxImageView.image = self.resizeImage(image: pickedImage, newWidth: 200)
        isRoadTaxTaken = true
      } else {
        insuranceCovernoteImageView.contentMode = .scaleAspectFit
        insuranceCovernoteImageView.image = self.resizeImage(image: pickedImage, newWidth: 200)
        isInsuranceCovernoteTaken = true
      }
    }
    picker.dismiss(animated: true, completion: nil)
  }
}
