//  Created by Hoang Le on 6/13/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import SnapKit
import Contacts

class ContactsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView  =   UITableView()
    
    var allContacts: [CNContact] = [CNContact]()
    
    var reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.view.addSubview(self.tableView)
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.rowHeight = 26
        //self.tableView.contentInset = UIEdgeInsetsMake(0, -5, 0, 0);
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
        }
        
        findContactsOnBackgroundThread(loadContacts)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
        cell?.textLabel?.text = CNContactFormatter.stringFromContact(allContacts[indexPath.row], style: .FullName)
        cell?.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        cell?.layoutMargins = UIEdgeInsetsZero
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let fullName = CNContactFormatter.stringFromContact(allContacts[indexPath.row], style: .FullName)
        
        var message = ""
        
//        if (allContacts[indexPath.row].isKeyAvailable(CNContactPhoneNumbersKey)) {
//            for phoneNumber:CNLabeledValue in allContacts[indexPath.row].phoneNumbers {
//                let p = phoneNumber.value as! CNPhoneNumber
//                message += "\n \(p.stringValue)"
//            }
//        }
        
        if (allContacts[indexPath.row].isKeyAvailable(CNContactPhoneNumbersKey)) {
            for socialProfile:CNLabeledValue in allContacts[indexPath.row].socialProfiles {
                let p = socialProfile.value as! CNSocialProfile
                message += "\n \(p.service) \(p.username)"
            }
        }
        
        let controller = UIAlertController(title: fullName, message: message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        controller.addAction(action)
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func loadContacts(contacts: [CNContact]?) {
        allContacts = contacts!
        tableView.reloadData()
    }
    
    func findContactsOnBackgroundThread(completionHandler:(contacts:[CNContact]?)->()) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            let fetchRequest = CNContactFetchRequest( keysToFetch: self.allowedContactKeys())
            var contacts = [CNContact]()
            CNContact.localizedStringForKey(CNLabelPhoneNumberiPhone)
            
            fetchRequest.mutableObjects = false
            fetchRequest.unifyResults = true
            fetchRequest.sortOrder = .UserDefault
            
            let contactStoreID = CNContactStore().defaultContainerIdentifier()
            print("\(contactStoreID)")
            
            
            do {
                
                try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) -> Void in
                    //do something with contact
                    //                    if contact.phoneNumbers.count > 0 {
                    contacts.append(contact)
                    //                    }
                    
                }
            } catch let e as NSError {
                print(e.localizedDescription)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(contacts: contacts)
                
            })
        })
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        return [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                CNContactNamePrefixKey,
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactOrganizationNameKey,
                CNContactBirthdayKey,
                CNContactImageDataKey,
                CNContactThumbnailImageDataKey,
                CNContactImageDataAvailableKey,
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey,
                CNContactSocialProfilesKey,
        ]
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}