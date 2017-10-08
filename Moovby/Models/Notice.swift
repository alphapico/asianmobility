//
//  Notice.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 27/09/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import ObjectMapper

struct Notice: Mappable {

  var id: Int!
  var userId: Int!
  var bookingId: Int!
  var title: String!
  var body: String!
  var image: UIImage?
  var noticeType: String!
  var isRead: Bool!
  var isSticky: Bool!
  var createdAt: Date!
  var updatedAt: Date!
  var url: URL!

  init?(map: Map) {}

  mutating func mapping(map: Map) {
    id          <- map["id"]
    userId      <- map["user_id"]
    bookingId   <- map["booking_id"]
    title       <- map["title"]
    body        <- map["body"]
    image       <- map["image"]
    noticeType  <- map["notice_type"]
    isRead      <- map["is_read"]
    isSticky    <- map["is_sticky"]
    createdAt   <- (map["created_at"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    updatedAt   <- (map["updated_at"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
    url         <- map["url"]
  }
}
