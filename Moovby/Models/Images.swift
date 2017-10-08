//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Images: Object, Mappable {

  dynamic var defaultImageUrl: String = ""
  
  private dynamic var _heroImage: MoovbyImage?
  var heroImage: MoovbyImageProtocol? {
    get {
      return _heroImage
    } set {
      _heroImage = newValue as? MoovbyImage
    }
  }
  
  private dynamic var _listingImage: MoovbyImage?
  var listingImage: MoovbyImageProtocol? {
    get {
      return _listingImage
    } set {
      _listingImage = newValue as? MoovbyImage
    }
  }
  
  private dynamic var _mainImage: MoovbyImage?
  var mainImage: MoovbyImageProtocol? {
    get {
      return _mainImage
    } set {
      _mainImage = newValue as? MoovbyImage
    }
  }
  
  private dynamic var _thumbnailImage: MoovbyImage?
  var thumbnailImage: MoovbyImageProtocol? {
    get {
      return _thumbnailImage
    } set {
      _thumbnailImage = newValue as? MoovbyImage
    }
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map){
    defaultImageUrl <- map["url"]
    _heroImage <- map["hero"]
    _listingImage <- map["listing"]
    _mainImage <- map["main"]
    _thumbnailImage <- map["thumb"]
  }
}
