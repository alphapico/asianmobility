//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import GoogleMaps

class MapMarker: GMSMarker {
  var car: Car?
  
  init(car: Car) {
    super.init()
    self.car = car
    position = CLLocationCoordinate2D(latitude: CLLocationDegrees(car.latitude) , longitude: CLLocationDegrees(car.longitude))
    icon = UIImage(named: "availableCar")
    appearAnimation = GMSMarkerAnimation.pop
  }
}
