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
        
        // The output below is limited by 1 KB.
        // Please Sign Up (Free!) to remove this limitation.
        
        // Instance creation.
        let tabBarController = ESTabBarController(tabIconNames: ["archive", "clock", "target", "map", "globe"])
        self.addChildViewController(tabBarController)
        self.view.addSubview(tabBarController.view)
        tabBarController.view.frame = self.view.bounds
        tabBarController.didMoveToParentViewController(self)
        tabBarController.selectionIndicatorHeight = 2;
        tabBarController.selectedColor = UIColor(hexString: "#CD5B45")
        tabBarController.buttonsBackgroundColor = UIColor(hexString: "#FFF")
//        tabBarController.selectedColor = [UIColor blackColor];
//        tabBarController.buttonsBackgroundColor = [UIColor colorWithHexString:@"#F6EBE0"];
        
        // View controllers.
        tabBarController.setViewController(FriendsController(), atIndex: 0)
        tabBarController.setViewController(HomeController(), atIndex: 1)
//        tabBarController.setViewController(MapViewController(), atIndex: 3)
//        tabBarController.setViewController(GlobeViewController(), atIndex: 4)
        
        tabBarController.setAction({
            self.presentViewController(CameraViewController(), animated: true, completion: nil)
        }, atIndex: 2)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

