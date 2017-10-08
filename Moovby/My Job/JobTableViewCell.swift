//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import GoogleMaps

class JobTableViewCell: UITableViewCell {
  
  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var carTitleLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var statusViewContainer: UIView!
  @IBOutlet weak var promoCodeViewContainer: UIView!
  @IBOutlet weak var promoCodeLabel: UILabel!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var isPaidLabel: UILabel!
  @IBOutlet var startDateLabel: UILabel!
//  @IBOutlet var paymentButton: UIButton!
//  @IBOutlet var paymentButtonHeightConstraint: NSLayoutConstraint!
//  @IBOutlet var buttonContainerHeightConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    promoCodeViewContainer.layer.cornerRadius = 5
    statusViewContainer.layer.cornerRadius = 5
    mapView.isUserInteractionEnabled = false
//    paymentButton.layer.cornerRadius = 5
  }
  
  func configure(viewModel: JobCellViewModel) {
    loadMap(latitude: viewModel.latitude(), longitude: viewModel.longitude())
    carTitleLabel.text = viewModel.carTitle()
    priceLabel.text = viewModel.price()
    statusLabel.text = viewModel.status()
    
    if viewModel.promoCode().isEmpty {
      promoCodeViewContainer.isHidden = true
      promoCodeLabel.isHidden = true
    } else {
      promoCodeLabel.text = viewModel.promoCode()
    }
    
    if viewModel.status() == "Paid" {
      isPaidLabel.isHidden = true
    } else {
      isPaidLabel.isHidden = false
      isPaidLabel.text = viewModel.isPaid()
    }
    startDateLabel.text = viewModel.startDate()
    
    if viewModel.status() == "Cancelled" {
      statusViewContainer.backgroundColor = UIColor.moovbyRed
    } else if viewModel.status() == "Rejected" {
      statusViewContainer.backgroundColor = UIColor.moovbyPurple
    }else {
      statusViewContainer.backgroundColor = UIColor.moovbyGreen
    }
  }
  
  func loadMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12.0)
    mapView.camera = camera
    let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let marker = GMSMarker(position: position)
    marker.map = mapView
    
    do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }
  }
}
