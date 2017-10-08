//
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Alamofire
import RealmSwift
import ObjectMapper
import PKHUD

class JobViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet var jobTableView: UITableView!
  let cellReuseIdentifier = "JobTableViewCell"
  let viewModel = JobViewModel()
  let moovbyProvider = MoovbyProvider()
  let realm = try! Realm()
//  let notificationName = Notification.Name(rawValue: "CancelBookingNotificationIdentifier")
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    self.navigationItem.title = "My Jobs"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    jobTableView.emptyDataSetSource = self
    jobTableView.emptyDataSetDelegate = self
    
    jobTableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
    jobTableView.rowHeight = UITableViewAutomaticDimension
    jobTableView.estimatedRowHeight = 250
    jobTableView.tableFooterView = UIView()
    
//    NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: notificationName, object: nil)
    
    requestCurrentJob { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadJobs()
        self.jobTableView.reloadData()
      }
      HUD.hide()
    }
    
    requestPastJob { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadJobs()
        self.jobTableView.reloadData()
      }
      HUD.hide()
    }
    
    jobTableView.reloadData()
  }
  
  func refreshView() {
    requestCurrentJob { (success) in
      if success {
        HUD.hide()
        self.viewModel.loadJobs()
        self.jobTableView.reloadData()
      }
      HUD.hide()
    }
    
    jobTableView.reloadData()
  }
  
  @IBAction func cancelButtonDidTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch segmentedControl.selectedSegmentIndex
    {
    case 0:
      self.viewModel.loadJobs()
    case 1:
      self.viewModel.loadPastJob()
    default:
      break
    }
    return viewModel.numberOfItems()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch segmentedControl.selectedSegmentIndex
    {
    case 0:
      self.viewModel.loadJobs()
    case 1:
      self.viewModel.loadPastJob()
    default:
      break
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    guard let jobCell = cell as? JobTableViewCell,
      let job = viewModel.itemAtIndex(index: indexPath.row) else {
        return UITableViewCell()
    }
    jobCell.configure(viewModel: JobCellViewModel(jobs: job))
    
    return jobCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let jobItem = viewModel.itemAtIndex(index: indexPath.row)
    let jobDetailViewController = JobDetailViewController.instantiate()
    jobDetailViewController.job = jobItem
    self.navigationController?.pushViewController(jobDetailViewController, animated: true)
  }
  
  static func instantiate() -> JobViewController {
    return UIStoryboard(name: "JobStoryboard", bundle: nil).instantiateViewController(withIdentifier: "JobViewController") as! JobViewController
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "There's no job available.")
  }
  
  // MARK: - DZNEmptyDataSetDelegate
  deinit {
    jobTableView.emptyDataSetSource = nil
    jobTableView.emptyDataSetDelegate = nil
//    NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
  }
  
  @IBAction func segmentedIndexChanged(_ sender: Any) {
    jobTableView.reloadData()
  }
  
  func requestCurrentJob(completion: @escaping(_ success: Bool) -> Void) {
    HUD.show(.progress)
    Alamofire.request("\(moovbyProvider.baseURL)/jobs/current", headers: moovbyProvider.headers()).responseJSON { (response) in
      if response.response?.statusCode == 200 {
        let jobResult = RealmRepository().objects(type: JobResult.self).first
        let jobs = RealmRepository().objects(type: Jobs.self)
        
        let currentjobs = Mapper<JobResult>().map(JSON: response.result.value as! [String : Any], toObject: JobResult())
        
        try! self.realm.write {
          for job in jobs {
            RealmRepository().deleteObject(object: job)
          }
          if jobResult != nil {
            RealmRepository().deleteObject(object: jobResult!)
          }
          self.realm.add(currentjobs, update: true)
        }
        
        completion(true)
      } else {
        HUD.hide()
        self.presentAlertController()
      }
      
    }
  }
  
  func requestPastJob(completion: @escaping(_ success: Bool) -> Void) {
    HUD.show(.progress)
    Alamofire.request("\(moovbyProvider.baseURL)/jobs/history", headers: moovbyProvider.headers()).responseJSON { (response) in
      if response.response?.statusCode == 200 {
        let currentjobs = Mapper<JobResult>().map(JSON: response.result.value as! [String : Any], toObject: JobResult())
        
        try! self.realm.write {
          self.realm.add(currentjobs, update: true)
        }
        completion(true)
      } else {
        HUD.hide()
        self.presentAlertController()
      }
    }
  }
  
  func presentAlertController() {
    let alertController = UIAlertController(title: "Oops!", message: "Fail to get list of jobs. Please try again later. Thank you.", preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
    {
      (result : UIAlertAction) -> Void in
    }
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

}
