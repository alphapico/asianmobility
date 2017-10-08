//
//  VerifyDocumentsController.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 07/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire

class VerifyDocumentsController: UIViewController {

  // MARK: - Outlets

  @IBOutlet weak var roadtaxImageView: UIImageView! {
    didSet {
      roadtaxImageView.setupBorder()
      roadtaxImageView.layer.cornerRadius = 4
    }
  }
  @IBOutlet weak var insuranceImageView: UIImageView! {
    didSet {
      insuranceImageView.setupBorder()
      insuranceImageView.layer.cornerRadius = 4
    }
  }
  @IBOutlet weak var nextButton: UIButton! {
    didSet {
      nextButton.layer.cornerRadius = nextButton.frame.size.height / 2
    }
  }

  // MARK: - Properties

  fileprivate var isRoadTaxPhoto = false
  fileprivate var isRoadTaxTaken = false
  fileprivate var isInsuranceTaken = false
  let moovbyProvider = MoovbyProvider()
  var vehicle: OwnerVehicle!

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Add new vehicle"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
  }

  @IBAction func tapSubmitButton(_ sender: Any) {
    let userRepo = UserLoginRepository().users().first
    guard let userId = userRepo?.id else { return }
    guard let roadtaxBase64Image = roadtaxImageView.image?.base64(format: .png) else {
      return
    }
    guard let insuranceBase64Image = insuranceImageView.image?.base64(format: .png) else {
      return
    }
    let url = "\(moovbyProvider.baseURL)/users/\(userId)/vehicles"

    let parameters: Parameters = [
      "vehicle_detail_id": vehicle.vehicleDetailId,
      "year": vehicle.year,
      "transmission": vehicle.transmission,
      "color": vehicle.color,
      "plate_num": vehicle.plateNumber,
      "is_available": true,
      "description": vehicle.description,
      "roadtax": roadtaxBase64Image,
      "insurance_covernote": insuranceBase64Image,
      "address": "",
      "latitude": "",
      "longitude": ""
    ]

    Alamofire.request(
      url,
      method: .post,
      parameters: parameters,
      encoding: JSONEncoding.default,
      headers: moovbyProvider.headers())
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode else { return }
        if statusCode == 200 {
          // Handle response
          self.navigationController?.popToRootViewController(animated: true)
        } else {
          print("Failed")
        }
    }
  }
}

// MARK: - Methods

extension VerifyDocumentsController {
  fileprivate func configureUI() {
    roadtaxImageView.addGestureRecognizer(
      UITapGestureRecognizer(target: self,
                             action: #selector(tapRoadtaxImageView))
    )
    insuranceImageView.addGestureRecognizer(
      UITapGestureRecognizer(target: self,
                             action: #selector(tapInsuranceImageView))
    )
  }

  func tapRoadtaxImageView() {
    isRoadTaxPhoto = true
    openCamera()
  }

  func tapInsuranceImageView() {
    isRoadTaxPhoto = false
    openCamera()
  }

  func openCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true, completion: nil)
    }
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
}

// MARK: - UIImagePickerController Delegates

extension VerifyDocumentsController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      if isRoadTaxPhoto {
        roadtaxImageView.contentMode = .scaleAspectFit
        roadtaxImageView.image = self.resizeImage(image: pickedImage, newWidth: 200)
        isRoadTaxTaken = true
      } else {
        insuranceImageView.contentMode = .scaleAspectFit
        insuranceImageView.image = self.resizeImage(image: pickedImage, newWidth: 200)
        isInsuranceTaken = true
      }
    }
    picker.dismiss(animated: true, completion: nil)
  }
}

// MARK: - UINavigationController Delegates

extension VerifyDocumentsController: UINavigationControllerDelegate {}
