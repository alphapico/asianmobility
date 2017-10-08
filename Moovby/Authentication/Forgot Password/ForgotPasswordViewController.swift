//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UIWebViewDelegate {

  // MARK: - Outlets

  @IBOutlet var webView: UIWebView!

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.delegate = self
    if let url = URL(string: "https://moovby.com/users/password/new") {
      let request = URLRequest(url: url)
      webView.loadRequest(request)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  // MARK: - Actions

  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - Methods

extension ForgotPasswordViewController {
  static func instantiate() -> ForgotPasswordViewController {
    return UIStoryboard(name: "ForgotPasswordStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
  }
}
