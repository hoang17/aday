//
//  MainController.swift
//  Group
//
//  Created by Hoang Le on 9/11/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import ESTabBarController
import UIColor_HexString

class MainController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tabBarController = ESTabBarController(tabIconNames: ["clock", "target", "map"])
        
//        let tabBarController = ESTabBarController(tabIconNames: ["archive", "clock", "target", "map", "globe"])
        
        self.addChildViewController(tabBarController)
        self.view.addSubview(tabBarController.view)
        tabBarController.view.frame = self.view.bounds
        tabBarController.didMoveToParentViewController(self)
        tabBarController.selectionIndicatorHeight = 3;
        tabBarController.selectedColor = UIColor(hexString: "#CD5B45")
        tabBarController.buttonsBackgroundColor = UIColor(hexString: "#F6EBE0")
//        tabBarController.buttonsBackgroundColor = UIColor(hexString: "#FFF")
        
        // View controllers.
        tabBarController.setViewController(FriendsController(), atIndex: 0)
        tabBarController.setViewController(ProfileController(), atIndex: 2)
        
        tabBarController.setAction({
            self.presentViewController(CameraViewController(), animated: true, completion: nil)
        }, atIndex: 1)

//        tabBarController.highlightButtonAtIndex(1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

