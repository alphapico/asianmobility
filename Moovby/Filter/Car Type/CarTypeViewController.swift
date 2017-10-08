//
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit

protocol CarTypeProtocol {
  func selectedCarType(carType: String)
}

class CarTypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var carTypeTableView: UITableView!
  var delegate: CarTypeProtocol?
  let viewModel = CarTypeViewModel()
  let cellIdentifier = "CarTypeTableViewCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    carTypeTableView.tableFooterView = UIView()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = carTypeTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    cell.textLabel?.text = viewModel.itemAtIndex(index: indexPath.row)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.selectedCarType(carType: self.viewModel.itemAtIndex(index: indexPath.row))
    _ = navigationController?.popViewController(animated: true)
  }
}
