//
//  CustomTabBarController.swift
//  Busanify
//
//  Created by 이인호 on 9/27/24.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewControllers?[0].tabBarItem.title = NSLocalizedString("home", comment: "")
        self.viewControllers?[1].tabBarItem.title = NSLocalizedString("bookmark", comment: "")
        self.viewControllers?[2].tabBarItem.title = NSLocalizedString("community", comment: "")
        self.viewControllers?[3].tabBarItem.title = NSLocalizedString("setting", comment: "")
    }
}
