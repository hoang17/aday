//
//  Created by Hoang Le on 6/17/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SnapKit
import Former

class AddPostController: FormViewController {
    
    var roomId : String?
    var postTitle : String?
    var postBody : String?
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    convenience init(roomId: String?) {
        self.init()
        self.roomId = roomId
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10

        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            }.configure {
                $0.placeholder = "Please enter post title"
            }.onTextChanged{ self.postTitle = $0}
        
        let bodyRow = TextViewRowFormer<FormTextViewCell>() { [self]
            $0.textView.font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
            $0.textView.inputAccessoryView = self.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Please enter post body"
                $0.rowHeight = 300
            }.onTextChanged{ self.postBody = $0}
        
        
        // Create SectionFormers
        
        let titleSection = SectionFormer(rowFormer: titleRow)
            .set(headerViewFormer: createHeader("Title"))
        let noteSection = SectionFormer(rowFormer: bodyRow)
            .set(headerViewFormer: createHeader("Body"))
        
        former.append(sectionFormer: titleSection, noteSection).onCellSelected { [weak self] _ in
            self?.formerInputAccessoryView.update()
        }
        
        // Setup Send button
        let button = UIButton(type: .System)
        button.setTitle("Send", forState: .Normal)
        button.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button.backgroundColor = view.tintColor
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(sendPost), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        button.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-20)
            make.left.equalTo(self.view).offset(200)
            make.right.equalTo(self.view).offset(-20)
        }

        // Setup Canel button
        let button1 = UIButton(type: .System)
        button1.setTitle("Cancel", forState: .Normal)
        button1.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        button1.backgroundColor = .grayColor()
        button1.layer.cornerRadius = 3
        button1.addTarget(self, action: #selector(cancel), forControlEvents: .TouchUpInside)
        self.view.addSubview(button1)
        button1.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-20)
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-200)
        }

    }

    // Create Headers
    
    let createHeader: (String -> ViewFormer) = { text in
        return LabelViewFormer<FormLabelHeaderView>()
            .configure {
                $0.viewHeight = 40
                $0.text = text
        }
    }

    func sendPost(){
        let ref = FIRDatabase.database().reference().child("posts")
        let id = ref.childByAutoId().key
        let uid = FIRAuth.auth()?.currentUser?.uid
        let uname = FIRAuth.auth()?.currentUser?.displayName
        let rid = roomId
        let post = Post(id: id, uid: uid!, uname: uname!, rid: rid!, title: postTitle!, body: postBody!)
        ref.child(id).setValue(post.toAnyObject())
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func cancel() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}