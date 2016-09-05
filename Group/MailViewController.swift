/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */
import UIKit
import MGSwipeTableCell

class MailData: NSObject {
    var from: String?
    var subject: String?
    var message: String?
    var date: String?
    var read = false
    var flag = false
}

typealias MailActionCallback = (cancelled: Bool, deleted: Bool, actionIndex: Int) -> Void

class MailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, UIActionSheetDelegate {

    var tableView: UITableView?
    var demoData = [MailData]()
    var actionCallback: MailActionCallback?
    var refreshControl: UIRefreshControl?
    
    func prepareDemoData() {
        var from: [AnyObject] = ["Vincent", "Mr Glass", "Marsellus", "Ringo", "Sullivan", "Mr Wolf", "Butch Coolidge", "Marvin", "Captain Koons", "Jules", "Jimmie Dimmick"]
        var subjects: [AnyObject] = ["You think water moves fast?", "They called me Mr Glass", "The path of the righteous man", "Do you see any Teletubbies in here?", "Now that we know who you are", "My money's in that office, right?", "Now we took an oath", "That show's called a pilot", "I know who I am. I'm not a mistake", "It all makes sense!", "The selfish and the tyranny of evil men"]
        var messages: [AnyObject] = ["You should see ice. It moves like it has a mind. Like it knows it killed the world once and got a taste for murder. After the avalanche, it took us a week to climb out.", "And I will strike down upon thee with great vengeance and furious anger those who would attempt to poison and destroy My brothers.", "Look, just because I don't be givin' no man a foot massage don't make it right for Marsellus to throw Antwone into a glass motherfuckin' house", "No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.", "In a comic, you know how you can tell who the arch-villain's going to be? He's the exact opposite of the hero", "If she start giving me some bullshit about it ain't there, and we got to go someplace else and get it, I'm gonna shoot you in the head then and there.", "that I'm breaking now. We said we'd say it was the snow that killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.", "Then they show that show to the people who make shows, and on the strength of that one show they decide if they're going to make more shows.", "And most times they're friends, like you and me! I should've known way back when...", "After the avalanche, it took us a week to climb out. Now, I don't know exactly when we turned on each other, but I know that seven of us survived the slide", "Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children"]
        for i in 0 ..< messages.count {
            let mail: MailData = MailData()
            mail.from = from[i] as? String
            mail.subject = subjects[i] as? String
            mail.message = messages[i] as? String
            mail.date = "11:\(43 - i)"
            demoData.append(mail)
        }
    }
    
    func refreshCallback() {
        self.prepareDemoData()
        tableView!.reloadData()
        refreshControl!.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.view.bounds, style: .Plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.view!.addSubview(tableView!)
        self.title = "MSwipeTableCell MailApp"
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(MailViewController.refreshCallback), forControlEvents: .ValueChanged)
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
    
    func mailForIndexPath(path: NSIndexPath) -> MailData {
        return demoData[path.row]
    }
    
    func updateCellIndicator(mail: MailData, cell: MailTableCell) {
        var color: UIColor?
        var innerColor : UIColor?
        if (!mail.read && mail.flag) {
            color = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
            innerColor = UIColor(red: 0, green: 122 / 255.0, blue: 1.0, alpha: 1.0)
        }
        else if (mail.flag) {
            color = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
        }
        else if (mail.read) {
            color = UIColor.clearColor()
        }
        else {
            color = UIColor(red: 0, green: 122 / 255.0, blue: 1.0, alpha: 1.0)
        }
        
        cell.indicatorView?.setIndicatorColor(color)
        cell.indicatorView?.setInnerColor(innerColor)
    }
    
    func showMailActions(mail: MailData, callback: MailActionCallback) {
        actionCallback = callback
        let sheet: UIActionSheet = UIActionSheet(title: "Actions",
                                                 delegate: self,
                                                 cancelButtonTitle: "Cancel",
                                                 destructiveButtonTitle: "Trash",
                                                 otherButtonTitles: mail.read ? "Mark as unread" : "Mark as read")
        sheet.showInView(self.view!)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        actionCallback!(cancelled: buttonIndex == actionSheet.cancelButtonIndex, deleted: buttonIndex == actionSheet.destructiveButtonIndex, actionIndex: buttonIndex)
        actionCallback = nil
    }
    
    func readButtonText(read: Bool) -> String {
        return read ? "Mark as\nunread" : "Mark as\nread"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier: String = "MailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? MailTableCell
        if (cell == nil) {
            cell = MailTableCell()
            cell!.delegate = self
        }
        let data: MailData = demoData[indexPath.row]
        cell!.mailFrom!.text = data.from
        cell!.mailSubject!.text = data.subject
        cell!.mailMessage!.text = data.message
        cell!.mailTime!.text = data.date
        self.updateCellIndicator(data, cell: cell!)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [AnyObject] {
        
        swipeSettings.transition = MGSwipeTransition.Border
        
        expansionSettings.buttonIndex = 0
        
        weak var me: MailViewController? = self
        
        let mail: MailData = me!.mailForIndexPath((self.tableView?.indexPathForCell(cell))!)
        
        if (direction == MGSwipeDirection.LeftToRight) {
            expansionSettings.fillOnTrigger = false
            expansionSettings.threshold = 2
            return [MGSwipeButton(title: me!.readButtonText(mail.read), backgroundColor: UIColor(red: 0, green: 122 / 255.0, blue: 1.0, alpha: 1.0), padding: 5, callback: {(sender: MGSwipeTableCell?) -> Bool in
                let mail: MailData = me!.mailForIndexPath((me!.tableView?.indexPathForCell(cell))!)
                mail.read = !mail.read
                me!.updateCellIndicator(mail, cell: (sender as! MailTableCell))
                cell.refreshContentView()
                //needed to refresh cell contents while swipping
                //change button text
                (cell.leftButtons[0] as! UIButton).setTitle(me!.readButtonText(mail.read), forState: .Normal)
                return true
            })]
        }
        else {
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 1.1
            let padding: CGFloat = 15
            let trash: MGSwipeButton = MGSwipeButton(title: "Trash", backgroundColor: UIColor(red: 1.0, green: 59 / 255.0, blue: 50 / 255.0, alpha: 1.0), padding: Int(padding), callback: {(sender: MGSwipeTableCell?) -> Bool in
                let indexPath: NSIndexPath = (me!.tableView?.indexPathForCell(cell))!
                me!.deleteMail(indexPath)
                return false
                //don't autohide to improve delete animation
            })
            let flag: MGSwipeButton = MGSwipeButton(title: "Flag", backgroundColor: UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0), padding: Int(padding), callback: {(sender: MGSwipeTableCell?) -> Bool in
                let mail: MailData = me!.mailForIndexPath((me!.tableView?.indexPathForCell(cell))!)
                mail.flag = !mail.flag
                me!.updateCellIndicator(mail, cell: (sender as! MailTableCell))
                cell.refreshContentView()
                //needed to refresh cell contents while swipping
                return true
            })
            let more: MGSwipeButton = MGSwipeButton(title: "More", backgroundColor: UIColor(red: 200 / 255.0, green: 200 / 255.0, blue: 205 / 255.0, alpha: 1.0), padding: Int(padding), callback: {(sender: MGSwipeTableCell?) -> Bool in
                let indexPath: NSIndexPath = (me!.tableView?.indexPathForCell(cell))!
                let mail: MailData = me!.mailForIndexPath(indexPath)
                let cell: MailTableCell = (sender as! MailTableCell)
                me!.showMailActions(mail, callback: {(cancelled: Bool, deleted: Bool, actionIndex: Int) -> Void in
                    if cancelled {
                        return
                    }
                    if deleted {
                        me!.deleteMail(indexPath)
                    }
                    else if actionIndex == 1 {
                        mail.read = !mail.read
                        (cell.leftButtons[0] as! UIButton).setTitle(me!.readButtonText(mail.read), forState: .Normal)
                        me!.updateCellIndicator(mail, cell: cell)
                        cell.refreshContentView()
                        //needed to refresh cell contents while swipping
                    }
                    else if actionIndex == 2 {
                        mail.flag = !mail.flag
                        me!.updateCellIndicator(mail, cell: cell)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}