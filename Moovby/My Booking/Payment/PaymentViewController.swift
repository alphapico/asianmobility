//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import PKHUD
//import EGHLPaymentLibrary

class PaymentViewController: UIViewController, UIWebViewDelegate {
  
  @IBOutlet var paymentWebView: UIWebView!
  let viewModel = PaymentViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /*let eghlPaymentView = EGHLPayment()
    self.view.addSubview(eghlPaymentView)
    
    let paymentRequestParam = PaymentRequestPARAM()
    let randomValue = arc4random_uniform(9999999 + 1)
    paymentRequestParam.paymentID = String(format: "CNASIT7791896%d", value)
    paymentRequestParam.orderNumber = String(format: "%d", value)
    paymentRequestParam.amount = "10"
    paymentRequestParam.merchantName = "Moovby Sdn Bhd"
    paymentRequestParam.custEmail = "rina.masrina92@gmail.com"
    paymentRequestParam.custName = "masrina"
    paymentRequestParam.serviceID = "GHL"
    paymentRequestParam.password = "ghl12345"
    paymentRequestParam.currencyCode = "MYR"
    
    
    eghlPaymentView.eghlRequestSale(paymentRequestParam, successBlock: { (success) in
      print("success: \(success)")
    }) { (error, msg) in
      print("\(error) \(msg)")
    }*/
    paymentWebView.delegate = self
    if let url = URL(string: viewModel.url()) {
      let request = URLRequest(url: url)
      paymentWebView.loadRequest(request)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "Payment"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  static func instantiate() -> PaymentViewController {
    return UIStoryboard(name: "PaymentStoryboard", bundle: nil).instantiateViewController(withIdentifier: "paymentViewControllerId") as! PaymentViewController
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    //self.navigationController?.popViewController(animated: true)
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - WebViewDelegate
  func webViewDidStartLoad(_ webView: UIWebView) {
    HUD.show(.progress)
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    HUD.hide()
  }
  
    // MARK: - eGHLDelegate
  
}
