//
//  PostCell.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/12/6.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: CircleView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var post: Post!
    
    func configureCell(post: Post, image: UIImage? = nil) {
        self.post = post
        self.caption.text = post.caption
        self.likes.text = String(post.likes)
        
        if image != nil {
            self.postImage.image = image
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("MARK: Unable to download from firebase")
                } else {
                    print("MARK: Image downloaded from firebase")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            FeedVC.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                                self.postImage.image = image
                        }
                    }
                }
            })
        }
    }
}
