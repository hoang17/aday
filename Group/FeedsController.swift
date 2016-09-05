//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import MGSwipeTableCell

class FeedsController: UITableViewController, MGSwipeTableCellDelegate, UIActionSheetDelegate {
    
    var feeds = [Feed]()
    
    var page: Page?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        
        // Setup table
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        self.title = page?.name

        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshCallback), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl!)
        self.prepareData()
    }
    
    func refreshCallback() {
        self.prepareData()
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    func prepareData(){
        let request = FBSDKGraphRequest(graphPath:"\((page?.id)!)/posts", parameters: ["fields": "message, description, story,type,link", "limit":"50"] );
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error == nil {
                
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                for i in 0 ..< data.count
                {
                    let dic : NSDictionary = data[i] as! NSDictionary
                    let id = dic.valueForKey("id") as! String
                    let type = dic.valueForKey("type") as? String
                    let link = dic.valueForKey("link") as? String
                    
                    var message = dic.valueForKey("name") as? String
                    if (message == nil){
                        message = dic.valueForKey("message") as? String
                    }
                    if (message == nil){
                        message = dic.valueForKey("description") as? String
                    }
                    if (message == nil){
                        message = dic.valueForKey("story") as? String
                    }
                    let feed = Feed(id:id, message:message, type: type, link:link)
                    self.feeds.append(feed)
                }
                
                self.tableView.reloadData()
                
            } else {
                print("Error: \(error)");
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? FeedTableCell
        
        if (cell == nil){
            cell = FeedTableCell(style: .Subtitle, reuseIdentifier: "cell")
            cell!.delegate = self
        }
        
        let feed = dataForIndexPath(indexPath)
        cell!.setTitle(feed.message!)
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feed = dataForIndexPath(indexPath)
        if (feed.link != nil){
            UIApplication.sharedApplication().openURL(NSURL(string: feed.link!)!)
        }
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [AnyObject] {
        
        swipeSettings.transition = MGSwipeTransition.ClipCenter
        swipeSettings.keepButtonsSwiped = false
        
        let color: UIColor = UIColor(red: 47 / 255.0, green: 47 / 255.0, blue: 49 / 255.0, alpha: 1.0)
        let redcolor = UIColor(red: 1.0, green: 59 / 255.0, blue: 50 / 255.0, alpha: 1.0)
        let greencolor = UIColor(red: 33 / 255.0, green: 175 / 255.0, blue: 67 / 255.0, alpha: 1.0)
        
        expansionSettings.buttonIndex = 0
        expansionSettings.threshold = 1.0
        expansionSettings.expansionLayout = MGSwipeExpansionLayout.Center
        expansionSettings.expansionColor = redcolor
        expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunction.CubicOut
        expansionSettings.fillOnTrigger = false
        
        let font: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        
        if (direction == MGSwipeDirection.LeftToRight) {
            
            let queueButton: MGSwipeButton = MGSwipeButton(title: "QUEUE", backgroundColor: color, padding: 15, callback: {(sender: MGSwipeTableCell!) -> Bool in
//                let page = self.dataForIndexPath((self.tableView?.indexPathForCell(sender))!)
//                NSLog("Queue song: %@", page.name)
                return true
            })
            queueButton.titleLabel!.font = font
            return [queueButton]
            
        }
        else {
            let saveButton: MGSwipeButton = MGSwipeButton(title: "REMOVE", backgroundColor: color, padding: 15, callback: {(sender: MGSwipeTableCell!) -> Bool in
//                let page = self.dataForIndexPath((self.tableView?.indexPathForCell(sender))!)
//                let indexPath: NSIndexPath = (self.tableView?.indexPathForCell(cell))!
//                self.deleteData(indexPath)
//                NSLog("Unlike page: %@", page.name)
                return false
            })
            saveButton.titleLabel!.font = font
            return [saveButton]
        }
    }

    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
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
    
    func dataForIndexPath(indexPath: NSIndexPath) -> Feed {
        return feeds[indexPath.row]
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}