//
//  WebViewController.swift
//  Pinly
//
//  Created by Hoang Le on 9/30/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webview = UIWebView(frame: UIScreen.mainScreen().bounds)
        webview.loadRequest(NSURLRequest(URL: NSURL(string: self.url)!))
        // webview.delegate = self
        self.view.addSubview(webview)
    }
}
