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
    
    var clip: ClipModel!
    var pid: String!
    
    var comments = [Comment]()
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    convenience init(clip: ClipModel){
        self.init()
        self.clip = clip
        self.pid = clip.id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true
        
        title = "Comments"
        
        textView.placeholder = "Write a comment..."

        self.inverted = false
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.textInputbar.autoHideRightButton = false
        self.registerPrefixesForAutoCompletion(["@",  "#", ":", "+:", "/"])
        self.textView.keyboardType = .Default
        
        // Todo: ob users typing in this thread
        //self.typingIndicatorView?.insertUsername("John")
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("threads/\(pid)/comments").observeEventType(.ChildAdded, withBlock: { snapshot in
            
            let comment = Comment(snapshot: snapshot)
            self.comments.append(comment)
            let realm = AppDelegate.realm
            comment.user = realm.objectForPrimaryKey(UserModel.self, key: comment.uid)
           
            let indexPath = NSIndexPath(forRow: self.comments.count-1, inSection: 0)
            
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //tableView.layoutMargins = UIEdgeInsetsZero
        //tableView.separatorInset = UIEdgeInsetsZero
        //tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        //tableView.separatorStyle = .None
    }
    
//    override func didChangeAutoCompletionPrefix(prefix: String, andWord word: String) {
//        
//        let array: NSArray = self.channels
//        
//        if prefix == "#" && word.characters.count > 0 {
//            self.searchResult = array.filteredArrayUsingPredicate(NSPredicate(format: "self BEGINSWITH[c] %@", word))
//        }
//        
//        let show = (self.searchResult.count > 0)
//        
//        self.showAutoCompletionView(show)
//    }
//    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        if tableView.isEqual(tableView) {
//            var item = self.searchResult[indexPath.row]
//            item += " "  // Adding a space helps dismissing the auto-completion view
//            
//            self.acceptAutoCompletionWithString(item)
//        }
//    }
    
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(sender: AnyObject?) {
        
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        if textView.text != "" {
            FriendsLoader.sharedInstance.comment(clip, text: textView.text!)
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
