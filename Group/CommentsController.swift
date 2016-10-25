//
//  CommentsController.swift
//  Pinly
//
//  Created by Hoang Le on 10/24/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentsController: UITableViewController, UITextFieldDelegate {
    
    var pid: String!
    
    var comments = [Comment]()
    
    convenience init(pid: String){
        self.init()
        self.pid = pid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        
        title = "Comments"
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("comments/\(pid)").observeEventType(.ChildAdded, withBlock: { snapshot in
            
            let comment = Comment(snapshot: snapshot)
            self.comments.append(comment)
            let realm = AppDelegate.realm
            comment.user = realm.objectForPrimaryKey(UserModel.self, key: comment.uid)
           
            let indexPath = NSIndexPath(forRow: self.comments.count-1, inSection: 0)
            
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            
//            ref.child("users").child(comment.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                comment.user = User(snapshot: snapshot)
//                
//                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.comments.indexOf(comment)!, inSection: 0)], withRowAnimation: .Automatic)
//                //let user = UserModel(user: data)
//            })
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.layoutMargins = UIEdgeInsetsZero
        //tableView.separatorInset = UIEdgeInsetsZero
        //tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        //tableView.separatorStyle = .None
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let comment = comments[indexPath.row]
        let height = self.heightForView(comment.txt, font: UIFont.systemFontOfSize(12.0))
        return height + 40
    }
    
    func heightForView(text:String, font: UIFont?) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.width-60, 24))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.height
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = CommentCell(comment: comment)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMore))
//        cell.moreButton.addGestureRecognizer(tap)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
}
