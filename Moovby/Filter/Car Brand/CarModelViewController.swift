//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

protocol CarModelProtocol {
  func selectedCarModel(carModel: String)
}

class CarModelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet var carModelTableView: UITableView!
  var delegate: CarModelProtocol?
  let cellIdentifier = "CarModelTableViewCell"
  let viewModel = CarModelViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    carModelTableView.tableFooterView = UIView()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = carModelTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    cell.textLabel?.text = viewModel.itemAtIndex(indexPath: indexPath.row)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = carModelTableView.cellForRow(at: indexPath)
    cell?.setSelected(true, animated: false)
    self.delegate?.selectedCarModel(carModel: self.viewModel.itemAtIndex(indexPath: indexPath.row))
    _ = navigationController?.popViewController(animated: true)
  }
}
