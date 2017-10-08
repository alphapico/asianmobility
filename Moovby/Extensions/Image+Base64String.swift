//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

enum ImageFormat {
  case png
  case jpeg(CGFloat)
}

extension UIImage {
  func base64(format: ImageFormat) -> String {
    var imageData: Data
    switch format {
    case .png:
      imageData = UIImagePNGRepresentation(self)!
    case .jpeg(let compression):
      imageData = UIImageJPEGRepresentation(self, compression)!
    }
    return imageData.base64EncodedString(options: .lineLength64Characters)
  }
}
