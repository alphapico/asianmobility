//
//  Copyright © 2017 Masrina. All rights reserved.
//

import Foundation

class UserProfileViewModel: NSObject {
  let userRepo = UserLoginRepository().users().first
  let userProfileRepo = UserProfileRepository().profile().first
  
  func firstName() -> String {
    guard let firstName = userProfileRepo?.firstName else { return "" }
    return firstName
  }
  
  func lastName() -> String {
    guard let lastName = userProfileRepo?.lastName else { return "" }
    return lastName
  }
  
  func phoneNumber() -> String {
    guard let phoneNumber = userProfileRepo?.phoneNumber else { return "" }
    return phoneNumber
  }
  
  func email() -> String {
    guard let email = userRepo?.email else { return "" }
    return email
  }
}
