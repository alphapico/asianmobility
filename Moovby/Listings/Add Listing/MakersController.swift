//
//  MakersController.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 05/10/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class MakersController: UIViewController {

  // MARK: - Outlets

  @IBOutlet weak var tableView: UITableView!

  // MARK: - Properties

  let moovbyProvider = MoovbyProvider()
  var makers: [Maker] = []
  var vehicle = OwnerVehicle()

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = "Add new vehicle"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    requestMakers()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    title = ""
  }
}

// MARK: - Methods

extension MakersController {
  fileprivate func configureUI() {
    tableView.register(UINib(nibName: "MakerCell", bundle: nil),
                      forCellReuseIdentifier: "MakerCell")
    tableView.register(UINib(nibName: "MakerHeadCell", bundle: nil),
                       forCellReuseIdentifier: "MakerHeadCell")
    tableView.delegate = self
    tableView.dataSource = self
  }

  fileprivate func requestMakers() {
    let url = "\(moovbyProvider.baseURL)/makers"
    let headers = self.moovbyProvider.headers()

    Alamofire.request(url, headers: headers).responseJSON { response in
      guard let statusCode = response.response?.statusCode else { return }
      if statusCode == 200 {
        if let json = response.result.value as? [String: Any] {
          guard let result = Mapper<Maker>().mapArray(JSONArray: json["makers"] as! [[String: Any]]) else { return }
          self.makers = result
          self.tableView.reloadData()
        }
      }
    }
  }
}

// MARK: - UITableView Data Source

extension MakersController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return makers.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MakerCell",
                                             for: indexPath) as! MakerCell
    let maker = makers[indexPath.row]
    cell.configure(maker: maker)
    return cell
  }
}

// MARK: - UITableView Delegates

extension MakersController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableCell(withIdentifier: "MakerHeadCell") as! MakerHeadCell
    header.configure("What brand of vehicle maker's do you want to list?")
    return header
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 140
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let controller = ModelsController(nibName: "ModelsController", bundle: nil)
    controller.maker = makers[indexPath.row]
    controller.vehicle = vehicle
    self.navigationController?.pushViewController(controller, animated: true)
  }
}
