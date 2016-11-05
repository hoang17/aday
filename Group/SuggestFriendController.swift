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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        self.navigationItem.hidesBackButton = true
        //self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func dismiss(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
