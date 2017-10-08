//
//  CustomNavigationBar.swift
//  Moovby
//
//  Created by Faiz Mokhtar on 21/08/2017.
//  Copyright © 2017 Masrina. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }

    override func awakeFromNib() {
        self.configureUI()
    }

    func configureUI() {
        self.isTranslucent = false
        self.tintColor = UIColor.moovbyGreen
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.moovbyGreen]

        let backButtonImage = UIImage(named: "back")
        self.backIndicatorImage = backButtonImage
        self.backIndicatorTransitionMaskImage = backButtonImage
    }
}
