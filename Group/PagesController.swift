//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MGSwipeTableCell

class PagesController: UITableViewController, MGSwipeTableCellDelegate, UIActionSheetDelegate {
    
    var pages = Dictionary<String, [Page]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        
        // Setup table
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = "My Pages"
        self.tableView.rowHeight = 30
        
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
        let request = FBSDKGraphRequest(graphPath:"me/likes", parameters: ["fields": "name,category","limit":"100"] );
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            
            if error == nil {
                
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                
                if (self.pages.count > 0){
                    self.pages.removeAll()
                }
                
                for i in 0 ..< data.count
                {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.valueForKey("id") as! String
                    let name = valueDict.valueForKey("name") as! String
                    let category = valueDict.valueForKey("category") as! String
                    let page = Page(id: id, name: name, category: category)
                    
                    if (!self.pages.keys.contains(page.category)){
                        self.pages[page.category] = [Page]()
                    }
                    self.pages[page.category]?.append(page)
                }
                
                self.tableView.reloadData()
                
            } else {
                print("Error \(error)");
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(pages.keys)[section]
        return pages[key]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? MGSwipeTableCell
        
        if (cell == nil){
            
            cell = MGSwipeTableCell(style: .Subtitle, reuseIdentifier: "cell")
            
            cell!.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
//            cell!.textLabel!.textColor = UIColor(red: 152 / 255.0, green: 152 / 255.0, blue: 157 / 255.0, alpha: 1.0)
            
//            cell!.detailTextLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
//            cell!.detailTextLabel!.textColor = cell!.textLabel!.textColor
            
//            cell!.backgroundColor = UIColor(red: 15 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
//            cell!.selectionStyle = .None
            
            // Setup More button
//            let view: UIImageView = UIImageView(image: UIImage(named: "more.png"))
//            view.contentMode = .ScaleAspectFit
//            view.frame = CGRectMake(0, 0, 25, 25)
//            cell!.accessoryView = view

            cell!.delegate = self
            
//            cell?.layoutMargins = UIEdgeInsetsZero
        }

        let page = dataForIndexPath(indexPath)
        
        cell?.textLabel?.text = page.name
        
//        cell!.detailTextLabel!.text = page.category
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UILabel()
        header.font = UIFont(name: "HelveticaNeue", size: 16.0)
        header.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
        header.text = "  " + Array(pages.keys)[section]

        // Setup More button
//        let view: UIImageView = UIImageView(image: UIImage(named: "more.png"))
//        view.contentMode = .ScaleAspectFit
//        view.frame = CGRectMake(0, 0, 25, 25)
//        cell.accessoryView = view
        
        return header
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return pages.keys.count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(pages.keys)[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        let f = FeedsController()
        f.page = dataForIndexPath(indexPath)
        self.navigationController!.pushViewController(f, animated: true)
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
                let page = self.dataForIndexPath((self.tableView?.indexPathForCell(sender))!)
                NSLog("Queue song: %@", page.name)
                return true
            })
            queueButton.titleLabel!.font = font
            return [queueButton]
        
        }
        else {
            let saveButton: MGSwipeButton = MGSwipeButton(title: "REMOVE", backgroundColor: color, padding: 15, callback: {(sender: MGSwipeTableCell!) -> Bool in
                let page = self.dataForIndexPath((self.tableView?.indexPathForCell(sender))!)
                let indexPath: NSIndexPath = (self.tableView?.indexPathForCell(cell))!
                self.deleteData(indexPath)
                NSLog("Unlike page: %@", page.name)
                return false
            })
            saveButton.titleLabel!.font = font
            return [saveButton]
        }
    }
    
    func dataForIndexPath(indexPath: NSIndexPath) -> Page {
        let key = Array(pages.keys)[indexPath.section]
        return pages[key]![indexPath.row]
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func deleteData(indexPath: NSIndexPath) {
        
        if FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions") {
            print("granted publish_actions")
            
            let p = dataForIndexPath(indexPath)
            let key = Array(self.pages.keys)[indexPath.section]
            self.pages[key]!.removeAtIndex(indexPath.row)
            self.tableView!.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Top)

            let request = FBSDKGraphRequest(graphPath:"\(p.id)/likes", parameters: ["fields": "name,category"], HTTPMethod:"DELETE" );
            request.startWithCompletionHandler { (connection, result, error) -> Void in
                if error == nil {
                    print("Unlike sucessful");
                } else {
                    print("Error \(error)");
                }
            }
        }
        else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: {(result: FBSDKLoginManagerLoginResult?, error: NSError?) -> Void in
                if error == nil {
                    print(result)
                    // Todo something
                } else {
                    print("Error \(error)");
                }
            })
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}