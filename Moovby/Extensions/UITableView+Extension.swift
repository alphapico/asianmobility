//
//  UITableView+Sugar.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 24/08/2017.
//  Copyright © 2017 Moovby. All rights reserved.
//

import Foundation

protocol Reusable: class {
  static var reuseIdentifier: String { get }
  static var nib: UINib? { get }
}

extension Reusable {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
  static var nib: UINib? {
    return nil
  }
}

extension UITableView {
  func registerReusableCell<T: UITableViewCell where T: Reusable>(_: T.Type) {
    if let nib = T.nib {
      self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    } else {
      self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
  }

  func dequeueReusableCell<T: UITableViewCell>
    (for indexPath: IndexPath) -> T where T: Reusable {
      guard let cell = dequeueReusableCell(
        withIdentifier: T.reuseIdentifier,
        for: indexPath) as? T else {
          fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
      }
      return cell
  }
}
