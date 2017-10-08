//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit

protocol GeneralSelectionProtocol {
  func selectedItem(item: String, type: String)
}

class GeneralSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  var delegate: GeneralSelectionProtocol?
  var selectionItems: [String] = []
  var type: String = ""
  var viewModel: GeneralSelectionViewModel?
  let cellIdentifier = "ItemsTableViewCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = GeneralSelectionViewModel(items: selectionItems)
    tableView.tableFooterView = UIView()
  }
  
  static func instantiate() -> GeneralSelectionViewController {
    return UIStoryboard(name: "ListingsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GeneralSelectionViewController") as! GeneralSelectionViewController
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let numberOfItems = viewModel?.numberOfItems() else { return 0 }
    return numberOfItems
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    cell.textLabel?.text = viewModel?.itemAtIndex(index: indexPath.row)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.selectedItem(item: (self.viewModel?.itemAtIndex(index: indexPath.row))!, type: type)
    _ = navigationController?.popViewController(animated: true)
  }
}
