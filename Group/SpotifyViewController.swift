/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

import UIKit
import MGSwipeTableCell

class SongData: NSObject {
    var title: String = ""
    var album: String = ""
}

class SpotifyViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate {
    
    var tableView: UITableView?
    var demoData = [SongData]()
    var refreshControl: UIRefreshControl?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func prepareDemoData() {
        var titles: [AnyObject] = ["Vincent", "Mr Glass", "Marsellus", "Ringo", "Sullivan", "Mr Wolf", "Butch Coolidge", "Marvin", "Captain Koons", "Jules", "Jimmie Dimmick"]
        var albums: [AnyObject] = ["You think water moves fast?", "They called me Mr Glass", "The path of the righteous man", "Do you see any Teletubbies in here?", "Now that we know who you are", "My money's in that office, right?", "Now we took an oath", "That show's called a pilot", "I know who I am. I'm not a mistake", "It all makes sense!", "The selfish and the tyranny of evil men"]
        for i in 0 ..< titles.count {
            let song: SongData = SongData()
            song.title = titles[i] as! String
            song.album = albums[i] as! String
            demoData.append(song)
        }
    }
    
    func refreshCallback() {
        self.prepareDemoData()
        tableView?.reloadData()
        refreshControl!.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController!.setNavigationBarHidden(true, animated: false)
        self.tableView = UITableView(frame: self.view.bounds, style: .Plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.separatorColor = UIColor.clearColor()
        self.tableView!.backgroundColor = UIColor(red: 15 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
        self.view!.addSubview(tableView!)
        self.title = "Spotify App Demo"
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshCallback), forControlEvents: .ValueChanged)
        self.tableView!.addSubview(refreshControl!)
        self.prepareDemoData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView!.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView!.frame = self.view.bounds
    }
    
    func deleteMail(indexPath: NSIndexPath) {
        demoData.removeAtIndex(indexPath.row)
        tableView!.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
    }
    
    func songForIndexPath(path: NSIndexPath) -> SongData {
        return demoData[path.row]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier: String = "SongCell"
        var cell: MGSwipeTableCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? MGSwipeTableCell
        
        if (cell == nil){
            cell = MGSwipeTableCell(style: .Subtitle, reuseIdentifier: identifier)
            cell!.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 21.0)
            cell!.textLabel!.textColor = UIColor(red: 152 / 255.0, green: 152 / 255.0, blue: 157 / 255.0, alpha: 1.0)
            cell!.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
            cell!.detailTextLabel!.textColor = cell!.textLabel!.textColor
            cell!.backgroundColor = UIColor(red: 15 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
            cell!.selectionStyle = .None
            let view: UIImageView = UIImageView(image: UIImage(named: "more.png"))
            view.contentMode = .ScaleAspectFit
            view.frame = CGRectMake(0, 0, 25, 25)
            cell!.accessoryView = view
            cell!.delegate = self
        }
        
        let data: SongData = demoData[indexPath.row]
        cell!.textLabel!.text = data.title
        cell!.detailTextLabel!.text = data.album
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [AnyObject] {
        swipeSettings.transition = MGSwipeTransition.ClipCenter
        swipeSettings.keepButtonsSwiped = false
        expansionSettings.buttonIndex = 0
        expansionSettings.threshold = 1.0
        expansionSettings.expansionLayout = MGSwipeExpansionLayout.Center
        expansionSettings.expansionColor = UIColor(red: 33 / 255.0, green: 175 / 255.0, blue: 67 / 255.0, alpha: 1.0)
        expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunction.CubicOut
        expansionSettings.fillOnTrigger = false
        weak var me: SpotifyViewController? = self
        let color: UIColor = UIColor(red: 47 / 255.0, green: 47 / 255.0, blue: 49 / 255.0, alpha: 1.0)
        let font: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        if direction == MGSwipeDirection.LeftToRight {
            let queueButton: MGSwipeButton = MGSwipeButton(title: "QUEUE", backgroundColor: color, padding: 15, callback: {(sender: MGSwipeTableCell!) -> Bool in
                let song: SongData = me!.songForIndexPath((me!.tableView?.indexPathForCell(sender))!)
                NSLog("Queue song: %@", song.title)
                return true
            })
            queueButton.titleLabel!.font = font
            return [queueButton]
        }
        else {
            let saveButton: MGSwipeButton = MGSwipeButton(title: "SAVE", backgroundColor: color, padding: 15, callback: {(sender: MGSwipeTableCell!) -> Bool in
                let song: SongData = me!.songForIndexPath((me!.tableView?.indexPathForCell(sender))!)
                NSLog("Save song: %@", song.title)
                return true
                //don't autohide to improve delete animation
            })
            saveButton.titleLabel!.font = font
            return [saveButton]
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
    
}