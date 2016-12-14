//
//  FeedVC.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/12/1.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import Firebase
import FirebaseDatabase
class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.delegate = self
        feedTableView.dataSource = self
        signOutBtn.imageView?.contentMode = .scaleAspectFit
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.dataservice.REF_POST.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for data in snapshot {
                    if let postDic = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let post = Post(postKey: key, postData: postDic)
                        self.posts.append(post)
                    }
                }
            self.feedTableView.reloadData()
            }
            })
    }
    
    @IBAction func tapImagePicker(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutBtnTapped(_ sender: UIButton) {
        let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: KEY_USER_ID)
        if removeSuccessful {
            try! FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "goLoginView", sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
        } else {
            print("MAEK: a valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? PostCell{
            if let image = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, image: image)
                return cell
            } else {
                print("first download img")
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
    }
}
