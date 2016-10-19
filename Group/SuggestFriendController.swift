//
//  SuggestFriendController.swift
//  Pinly
//
//  Created by Hoang Le on 10/18/16.
//  Copyright © 2016 ping. All rights reserved.
//

import Foundation
import UIKit

class SuggestFriendController: SearchController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss))
    }
    
    func dismiss(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
