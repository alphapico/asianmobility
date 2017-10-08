//
//  InfoViewModle.swift
//  Moovby
//
//  Created by Masrina on 02/02/2017.
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation

class InfoViewModle {
  let booking: Bookings
  
  init(booking: Bookings) {
    self.booking = booking
  }
  
  func bookingId() -> Int {
    return booking.id
  }
  
  func address() -> String {
    return booking.address
  }
  
  func totalPrice() -> String {
    return booking.total
  }
}
