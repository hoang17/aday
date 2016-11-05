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
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true
        
        title = "Comments"
        
        textView.placeholder = "Write a comment..."

        self.isInverted = false
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.textInputbar.autoHideRightButton = false
        self.registerPrefixes(forAutoCompletion: ["@",  "#", ":", "+:", "/"])
        self.textView.keyboardType = .default
        
        // Todo: ob users typing in this thread
        //self.typingIndicatorView?.insertUsername("John")
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("threads/\(pid)/comments").observe(.childAdded, with: { snapshot in
            
            let comment = Comment(snapshot: snapshot)
            self.comments.append(comment)
            let realm = AppDelegate.realm
            comment.user = realm?.object(ofType: UserModel.self, forPrimaryKey: comment.uid)
           
            let indexPath = IndexPath(row: self.comments.count-1, section: 0)
            
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
    override func didPressRightButton(_ sender: Any?) {
        
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        if textView.text != "" {
            FriendsLoader.sharedInstance.comment(clip, text: textView.text!)
        }
        
        super.didPressRightButton(sender)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let comment = comments[indexPath.row]
        let height = self.heightForView(comment.txt, font: UIFont.systemFont(ofSize: 12.0))
        return height + 40
    }
    
    func heightForView(_ text:String, font: UIFont?) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.width-60, height: 24))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = CommentCell(comment: comment)
        //cell.transform = tableView.transform
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMore))
//        cell.moreButton.addGestureRecognizer(tap)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
}
