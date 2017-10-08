//
//  ModelsController.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 05/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class ModelsController: UIViewController {

  // MARK: - Outlets

  @IBOutlet weak var tableView: UITableView!

  // MARK: - Properties

  let moovbyProvider = MoovbyProvider()
  var models: [Model] = []
  var maker: Maker!
  var vehicle: OwnerVehicle!

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Add new vehicle"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    requestModels()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
  }
}

// MARK: - Methods

extension ModelsController {
  fileprivate func configureUI() {
    title = "Add new vehicle"
    tableView.register(UINib(nibName: "MakerHeadCell", bundle: nil),
                       forCellReuseIdentifier: "MakerHeadCell")
    tableView.register(UINib(nibName: "ModelCell", bundle: nil),
                       forCellReuseIdentifier: "ModelCell")

    tableView.delegate = self
    tableView.dataSource = self
  }

  fileprivate func requestModels() {
    let url = "\(moovbyProvider.baseURL)/vehicles_detail"
    let headers = self.moovbyProvider.headers()

    Alamofire.request(url, headers: headers).responseJSON { response in
      guard let statusCode = response.response?.statusCode else { return }
      if statusCode == 200 {
        if let json = response.result.value as? [String: Any] {
          guard let result = Mapper<Model>().mapArray(JSONArray: json["vehicle_detail"] as! [[String: Any]]) else { return }
          self.models = result.filter{ $0.makerId == self.maker.id}
          self.tableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableView Data Sources

extension ModelsController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell",
                                             for: indexPath) as! ModelCell
    let model = models[indexPath.row]
    cell.configure(model: model)
    return cell
  }
}

extension ModelsController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableCell(withIdentifier: "MakerHeadCell") as! MakerHeadCell

    header.configure("What is the model of your \(maker.brand.localizedCapitalized)?")
    return header
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 140
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let controller = PlateNumberController(nibName: "PlateNumberController", bundle: nil)
    let model = models[indexPath.row]
    vehicle.id = model.id
    vehicle.vehicleDetailId = model.makerId

    controller.vehicle = vehicle
    self.navigationController?.pushViewController(controller, animated: true)
  }
}
