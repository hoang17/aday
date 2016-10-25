//
//  CommentsController.swift
//  Pinly
//
//  Created by Hoang Le on 10/24/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SlackTextViewController

class CommentsController: SLKTextViewController, UITextFieldDelegate {
    
    var pid: String!
    
    var comments = [Comment]()
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    convenience init(pid: String){
        self.init()
        self.pid = pid
        self.inverted = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true
        
        title = "Comments"
        
        textView.placeholder = "Write a comment..."
        
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
    
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(sender: AnyObject?) {
        
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
//        let message = Message()
//        message.username = LoremIpsum.name()
//        message.text = self.textView.text
//        
//        let indexPath = IndexPath(row: 0, section: 0)
//        let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
//        let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
//        
//        self.tableView.beginUpdates()
//        self.messages.insert(message, at: 0)
//        self.tableView.insertRows(at: [indexPath], with: rowAnimation)
//        self.tableView.endUpdates()
//        
//        self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
//        
//        // Fixes the cell from blinking (because of the transform, when using translucent cells)
//        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
//        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if textView.text != "" {
            FriendsLoader.sharedInstance.comment(pid, text: textView.text!)
        }
        
        super.didPressRightButton(sender)
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
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = CommentCell(comment: comment)
        //cell.transform = tableView.transform
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMore))
//        cell.moreButton.addGestureRecognizer(tap)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
}
