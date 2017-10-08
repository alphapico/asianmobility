//
//  Model.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 06/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import ObjectMapper

struct Model: Mappable {
  var id: Int!
  var model: String!
  var makerId: Int!
  var hourlyPrice: String?
  var dailyPrice: String?
  var weeklyPrice: String?
  var monthlyPrice: String?
  var vehicleType: String?
  var cubicCentimetres: String?
  var seatNum: Int?
  var createdAt: Date!
  var updatedAt: Date!
  var imageUrl: URL?

  init?(map: Map) {}

  mutating func mapping(map: Map) {
    id                <- map["id"]
    model             <- map["model"]
    makerId           <- map["maker_id"]
    hourlyPrice       <- map["hourly_price"]
    dailyPrice        <- map["daily_price"]
    weeklyPrice       <- map["monthly_price"]
    monthlyPrice      <- map["monthly_price"]
    vehicleType       <- map["vehicle_type"]
    cubicCentimetres  <- map["cc"]
    seatNum           <- map["seat_num"]
    createdAt         <- map["created_at"]
    updatedAt         <- map["updated_at"]
    imageUrl          <- (map["default_img.url"], URLTransform())
  }
}
