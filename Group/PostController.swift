//
//  Created by Hoang Le on 6/17/16.
//  Copyright © 2016 ping. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Former

class PostController: FormViewController {
    
    var postId: String?
    
    convenience init(postId: String) {
        self.init()
        self.postId = postId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Headers
        
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 0
            }
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child("posts").child(postId!).observeEventType(.Value, withBlock: { snapshot in
            
            let post = Post(snapshot: snapshot)
            
            let row = CustomRowFormer<DynamicHeightCell>(instantiateType: .Nib(nibName: "DynamicHeightCell")) {
                $0.title = post.title
                $0.body = post.body
                }.configure {
                    $0.rowHeight = UITableViewAutomaticDimension
                }
            
            let section = SectionFormer(rowFormer: row).set(headerViewFormer: createSpaceHeader())
            
            self.former.append(sectionFormer: section)
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}