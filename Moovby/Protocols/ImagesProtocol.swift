//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

protocol ImagesProtocol {
  var defaultImageUrl: String { get set }
  var heroImage: MoovbyImageProtocol { get set }
  var listingImage: MoovbyImageProtocol { get }
  var mainImage: MoovbyImageProtocol { get }
  var thumbnailImage: MoovbyImageProtocol { get }
}
