//
//  PlateNumberController.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 06/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class PlateNumberController: UIViewController {

  // MARK: - Properties

  var vehicle: OwnerVehicle!
  let yearPickerData = ["2017", "2016", "2015", "2014", "2013", "2012", "2011", "2010", "2009", "2008", "2007"]
  let colorPickerData = ["White", "Black", "Yellow", "Blue", "Red", "Green"]
  let transmissionPickerData = ["Auto", "Manual"]

  var carPlateNumber: String = ""
  var carYear: String = ""
  var carColor: String = ""
  var carTransmission: String = ""
  var carDescription: String = ""

  // MARK: - Outlets

  var yearPickerView: UIPickerView = UIPickerView()
  var colorPickerView: UIPickerView = UIPickerView()
  var transmissionPickerView: UIPickerView = UIPickerView()

  @IBOutlet weak var plateNumberTextField: CustomTextField! {
    didSet {
      plateNumberTextField.placeholder = "Car's plate number"
      plateNumberTextField.textColor = UIColor.white
    }
  }
  @IBOutlet weak var yearTextField: CustomTextField! {
    didSet {
      yearTextField.placeholder = "Car's year"
      yearTextField.textColor = UIColor.white
    }
  }
  @IBOutlet weak var transmissionTextField: CustomTextField! {
    didSet {
      transmissionTextField.placeholder = "Car's transmission"
      transmissionTextField.textColor = UIColor.white
    }
  }
  @IBOutlet weak var colorTextField: CustomTextField! {
    didSet {
      colorTextField.placeholder = "Car's color"
      colorTextField.textColor = UIColor.white
    }
  }
  @IBOutlet weak var descriptionTextView: UITextView! {
    didSet {
      descriptionTextView.setupBorder()
      descriptionTextView.tintColor = UIColor.white
      descriptionTextView.textColor = UIColor.lightText
      descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
      descriptionTextView.text = "Car's description"
    }
  }
  @IBOutlet weak var nextButton: UIButton! {
    didSet {
      nextButton.backgroundColor = UIColor.white
      nextButton.tintColor = UIColor.moovbyGreen
      nextButton.layer.cornerRadius = nextButton.layer.frame.size.height / 2
    }
  }

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Add new vehicle"
    plateNumberTextField.becomeFirstResponder()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
  }

  // MARK: - Actions

  @IBAction func tappedNextButton(_ sender: Any) {
    let controller = VerifyDocumentsController(nibName: "VerifyDocumentsController", bundle: nil)

    if !carDescription.isEmpty && !carPlateNumber.isEmpty && !carColor.isEmpty && !carYear.isEmpty {
      vehicle.carDescription = carDescription
      vehicle.plateNumber = carPlateNumber
      vehicle.color = carColor
      vehicle.year = Int(carYear)!
      controller.vehicle = vehicle
      self.navigationController?.pushViewController(controller, animated: true)
    }
  }
}

// MARK: - Methods

extension PlateNumberController {
  func configureUI() {
    plateNumberTextField.delegate = self
    yearTextField.delegate = self
    transmissionTextField.delegate = self
    colorTextField.delegate = self
    descriptionTextView.delegate = self
  }
}

// MARK: - UITextField Delegates

extension PlateNumberController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    switch textField {
    case yearTextField:
      yearPickerView.delegate = self
      yearPickerView.dataSource = self
      textField.inputView = yearPickerView
    case colorTextField:
      colorPickerView.delegate = self
      colorPickerView.dataSource = self
      textField.inputView = colorPickerView
    case transmissionTextField:
      transmissionPickerView.delegate = self
      transmissionPickerView.dataSource = self
      textField.inputView = transmissionPickerView
    default:
      break
    }
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField {
    case plateNumberTextField:
      guard let text = plateNumberTextField.text else { break }
      carPlateNumber = text
    case yearTextField:
      guard let text = yearTextField.text else { break }
      carYear = text
    case colorTextField:
      guard let text = colorTextField.text else { break }
      carColor = text
      break
    case transmissionTextField:
      guard let text = transmissionTextField.text else { break }
      carTransmission = text
    default:
      break
    }
  }
}

// MARK: - UITextView Delegates

extension PlateNumberController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightText {
      textView.text = nil
      textView.textColor = UIColor.white
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Car's description"
      textView.textColor = UIColor.lightText
    }
    carDescription = textView.text
  }
}

// MARK: - UIPickerView Delegates

extension PlateNumberController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case yearPickerView:
      let selected = yearPickerData[row]
      yearTextField.text = selected
    case colorPickerView:
      let selected = colorPickerData[row]
      colorTextField.text = selected
    case transmissionPickerView:
      let selected = transmissionPickerData[row]
      transmissionTextField.text = selected
    default:
      break
    }
  }
}

// MARK: - UIPickerView Data Sources

extension PlateNumberController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView {
    case yearPickerView:
      return yearPickerData.count
    case colorPickerView:
      return colorPickerData.count
    case transmissionPickerView:
      return transmissionPickerData.count
    default:
      return 0
    }
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView {
    case yearPickerView:
      return yearPickerData[row]
    case colorPickerView:
      return colorPickerData[row]
    case transmissionPickerView:
      return transmissionPickerData[row]
    default:
      return nil
    }
  }
}
