//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import SnapKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase
import MGSwipeTableCell

typealias PostActionCallback = (cancelled: Bool, deleted: Bool, actionIndex: Int) -> Void

class RoomController: UITableViewController, MGSwipeTableCellDelegate, UIActionSheetDelegate {
    
    var posts = [Post]()
    
    var room: Room?
    
    var actionCallback: MailActionCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.title = room?.name
        
        // Setup add new post button
//        let button = UIButton(type: .System)
//        button.setTitle("Add New Post", forState: .Normal)
//        button.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
//        button.backgroundColor = view.tintColor
//        button.addTarget(self, action: #selector(addPost), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button)
//        button.snp_makeConstraints { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//            make.left.equalTo(self.view).offset(0)
//            make.right.equalTo(self.view).offset(0)
//        }
        
        // Setup posts table
        
        tableView.registerClass(PostTableCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        self.prepareData()
    }
    
    func prepareData(){
        let ref = FIRDatabase.database().reference()
        
        print("...loading post for room \(room!.id)...")
        
        ref.child("posts").queryOrderedByChild("rid").queryEqualToValue(room!.id).observeEventType(.Value, withBlock: { snapshot in
            
            print("...returning posts...")
            
            self.posts.removeAll()
            for item in snapshot.children {
                let post = Post(snapshot: item as! FIRDataSnapshot)
                self.posts.insert(post, atIndex: 0)
            }
            self.tableView.reloadData()
            
            print("...loaded \(self.posts.count) posts")
        })
    }
    
    func addPost(){
        let navViewController = self.parentViewController as! UINavigationController;
        navViewController.pushViewController(AddPostController(roomId: room!.id), animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PostTableCell
        let post = posts[indexPath.row]
        cell.setTitle(post.title)
        cell.setBody(post.body)
        cell.timeLabel!.text = "11:\(43 - indexPath.row)"
        cell.delegate = self
        cell.layoutMargins = UIEdgeInsetsZero
        self.updateCellIndicator(post, cell: cell)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let p = self.postForIndexPath(indexPath)
        var th = self.heightForView(p.title, font: UIFont(name: "HelveticaNeue", size: 13.0))
        var bh = self.heightForView(p.body, font: UIFont(name: "HelveticaNeue-Light", size: 12.0))
        
        if (th > 30){
            th = 30
        }
        else{
            th = 15
        }
        
        if (bh > 30){
            bh = 30
        }
        else{
            bh = 15
        }
        
        return th + bh + 15
    }
    
    func heightForView(text:String, font: UIFont?) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.height
    }
    
    func deletePost(indexPath: NSIndexPath) {
        posts.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
    }
    
    func postForIndexPath(path: NSIndexPath) -> Post {
        return posts[path.row]
    }
    
    func updateCellIndicator(post: Post, cell: PostTableCell) {
        var color: UIColor?
        var innerColor : UIColor?
        if (!post.read && post.flag) {
            color = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
            innerColor = UIColor(red: 0, green: 122 / 255.0, blue: 1.0, alpha: 1.0)
        }
        else if (post.flag) {
            color = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
        }
        else if (post.read) {
            color = UIColor.clearColor()
        }
        else {
            color = UIColor(red: 0, green: 122 / 255.0, blue: 1.0, alpha: 1.0)
        }
        
        cell.indicatorView?.setIndicatorColor(color)
        cell.indicatorView?.setInnerColor(innerColor)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController!.pushViewController(PostController(postId: posts[indexPath.row].id), animated: true)
        
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [AnyObject] {
        
        swipeSettings.transition = MGSwipeTransition.Border
        
        expansionSettings.buttonIndex = 0
        
        weak var me = self
        
        let post: Post = me!.postForIndexPath((self.tableView?.indexPathForCell(cell))!)
        
        if (direction == MGSwipeDirection.LeftToRight) {
            
            swipeSettings.keepButtonsSwiped = false
            
            expansionSettings.fillOnTrigger = false
            expansionSettings.threshold = 1.0
            expansionSettings.expansionLayout = MGSwipeExpansionLayout.Center
            expansionSettings.expansionColor = UIColor(red: 33 / 255.0, green: 175 / 255.0, blue: 67 / 255.0, alpha: 1.0)
            expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunction.CubicOut
            
            return [MGSwipeButton(title: me!.readButtonText(post.read), backgroundColor: UIColor(red: 0, green: 122 / 255.0, blue: 1.0, alpha: 1.0), padding: 5, callback: {(sender: MGSwipeTableCell?) -> Bool in
                let post: Post = me!.postForIndexPath((me!.tableView?.indexPathForCell(cell))!)
                post.read = !post.read
                post.ref?.updateChildValues(["read":post.read])
                me!.updateCellIndicator(post, cell: (sender as! PostTableCell))
                cell.refreshContentView()
                //needed to refresh cell contents while swipping
                //change button text
                (cell.leftButtons[0] as! UIButton).setTitle(me!.readButtonText(post.read), forState: .Normal)
                return true
            })]
        }
        else {
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 1.1
            let padding: CGFloat = 15
            let trash: MGSwipeButton = MGSwipeButton(title: "Trash", backgroundColor: UIColor(red: 1.0, green: 59 / 255.0, blue: 50 / 255.0, alpha: 1.0), padding: Int(padding), callback: {(sender: MGSwipeTableCell?) -> Bool in
                let indexPath: NSIndexPath = (me!.tableView?.indexPathForCell(cell))!
                me!.deletePost(indexPath)
                return false
                //don't autohide to improve delete animation
            })
            let flag: MGSwipeButton = MGSwipeButton(title: "Flag", backgroundColor: UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0), padding: Int(padding), callback: {(sender: MGSwipeTableCell?) -> Bool in
                let post: Post = me!.postForIndexPath((me!.tableView?.indexPathForCell(cell))!)
                post.flag = !post.flag
                me!.updateCellIndicator(post, cell: (sender as! PostTableCell))
                cell.refreshContentView()
                post.ref?.updateChildValues(["flag":post.flag])
                //needed to refresh cell contents while swipping
                return true
            })
            let more: MGSwipeButton = MGSwipeButton(title: "More", backgroundColor: UIColor(red: 200 / 255.0, green: 200 / 255.0, blue: 205 / 255.0, alpha: 1.0), padding: Int(padding), callback: {(sender: MGSwipeTableCell?) -> Bool in
                let indexPath: NSIndexPath = (me!.tableView?.indexPathForCell(cell))!
                let post: Post = me!.postForIndexPath(indexPath)
                let cell: PostTableCell = (sender as! PostTableCell)
                me!.showPostActions(post, callback: {(cancelled: Bool, deleted: Bool, actionIndex: Int) -> Void in
                    if cancelled {
                        return
                    }
                    if deleted {
                        me!.deletePost(indexPath)
                    }
                    else if actionIndex == 1 {
                        post.read = !post.read
                        (cell.leftButtons[0] as! UIButton).setTitle(me!.readButtonText(post.read), forState: .Normal)
                        me!.updateCellIndicator(post, cell: cell)
                        cell.refreshContentView()
                        //needed to refresh cell contents while swipping
                    }
                    else if actionIndex == 2 {
                        post.flag = !post.flag
                        me!.updateCellIndicator(post, cell: cell)
                        cell.refreshContentView()
                        //needed to refresh cell contents while swipping
                    }
                    
                    cell.hideSwipeAnimated(true)
                })
                return false
                //avoid autohide swipe
            })
            return [trash, flag, more]
        }
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        var str: String
        switch state {
        case MGSwipeState.None:
            str = "None"
        case MGSwipeState.SwipingLeftToRight:
            str = "SwipingLeftToRight"
        case MGSwipeState.SwipingRightToLeft:
            str = "SwipingRightToLeft"
        case MGSwipeState.ExpandingLeftToRight:
            str = "ExpandingLeftToRight"
        case MGSwipeState.ExpandingRightToLeft:
            str = "ExpandingRightToLeft"
        }
        
        NSLog("Swipe state: %@ ::: Gesture: %@", str, gestureIsActive ? "Active" : "Ended")
    }
    
    func readButtonText(read: Bool) -> String {
        return read ? "Mark as\nunread" : "Mark as\nread"
    }
    
    func showPostActions(post: Post, callback: PostActionCallback) {
        actionCallback = callback
        let sheet: UIActionSheet = UIActionSheet(title: "Actions",
                                                 delegate: self,
                                                 cancelButtonTitle: "Cancel",
                                                 destructiveButtonTitle: "Trash",
                                                 otherButtonTitles: post.read ? "Mark as unread" : "Mark as read")
        sheet.showInView(self.view!)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}