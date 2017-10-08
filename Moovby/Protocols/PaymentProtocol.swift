//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation

protocol PaymentProtocol {
  var id: Int { get set }
  var bookingId: Int { get set }
  var userId: Int { get set }
  var method: String { get set }
  var code: String { get set }
  var url: String { get set }
  var status: String { get set }
  var createdAt: String { get set }
  var updatedAt: String { get set }
}
