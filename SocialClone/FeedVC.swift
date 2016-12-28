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
class FeedVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var captionTextField: UITextField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageIsSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
        feedTableView.delegate = self
        feedTableView.dataSource = self
        signOutBtn.imageView?.contentMode = .scaleAspectFit
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.dataservice.REF_POST.observe(.value, with: { (snapshot) in
            self.posts = [] 
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for data in snapshot {
                    if let postDic = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let post = Post(postKey: key, postData: postDic)
                        self.posts.insert(post, at: 0)
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
    
    @IBAction func tapAddCaptionBtn(_ sender: CircleBtn) {
        guard let caption = captionTextField.text, caption != "" else {
            print("MARK: Caption field is empty")
            return
        }
        guard let img = addImage.image , imageIsSelected == true else {
            print("MARK: An image must selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = UUID().uuidString //create image unique id
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            DataService.dataservice.REF_POST_IMAGE.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print("MARK: Unable to upload image")
                } else {
                    print("MARK: Successfully upload image")
                    let downloadUrl = metaData?.downloadURL()?.absoluteString
                        if let imgUrl = downloadUrl {
                        self.postToFirebase(imgUrl: imgUrl)
                    }
                }
            }
            
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post : Dictionary<String, Any> = [
            "caption": captionTextField.text!,
            "image_url": imgUrl,
            "likes": 0
        ]
        let firebasePost = DataService.dataservice.REF_POST.childByAutoId()
        firebasePost.setValue(post)
        
        captionTextField.text = ""
        addImage.image = UIImage(named: "add-image")
        imageIsSelected = false
        feedTableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate
extension FeedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

}

// MARK: - UITableViewDataSource
extension FeedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? PostCell{
            if let image = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, image: image)
            } else {
                print("first download img")
                cell.configureCell(post: post)
            }
            return cell
        } else {
            return PostCell()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FeedVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageIsSelected = true
        } else {
            print("MAEK: a valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - dismiss textfield
extension FeedVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
