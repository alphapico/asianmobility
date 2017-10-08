//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController, UIWebViewDelegate {
  
  @IBOutlet var webView: UIWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.delegate = self
    if let url = URL(string: "https://www.moovby.com/pages/faq") {
      let request = URLRequest(url: url)
      webView.loadRequest(request)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "FAQ"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  static func instantiate() -> FAQViewController {
    return UIStoryboard(name: "FAQStoryboard", bundle: nil).instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
