//
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation
import Alamofire

class MoovbyProvider {

  let baseURL = Bundle.main.infoDictionary!["URL Endpoint"] as! String

  func headers() -> HTTPHeaders {
    print("Bearer \(userToken())")
    
    let assignHeaders = [
      "Authorization": "Bearer \(userToken())",
      "Content-Type": "application/json"]
    return assignHeaders
  }
  
  func userToken() -> String {
    let repo = UserLoginRepository().userLoginResult().first
    
    guard let token = repo?.authorizationToken else {
      return ""
    }
    
    return token
  }
  
  /*public static func endpointClosure(target: MoovbyService) -> Endpoint<MoovbyService> {
    let sampleResponseClosure = { return EndpointSampleResponse.networkResponse(200, target.sampleData) }
    
    let method = target.method
    let parameters = target.parameters
    let endpoint = Endpoint<MoovbyService>(url: url(route: target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters, parameterEncoding: target.parameterEncoding)
    return endpoint.adding(newHTTPHeaderFields: target.headers())
  }*/
  
  //public static func DefaultProvider() -> MoyaProvider<MoovbyService> {
  //  return MoyaProvider<MoovbyService>(endpointClosure: MoovbyProvider.endpointClosure(target: MoovbyService))
    //return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, manager: ElloManager.manager)
  //}
}
