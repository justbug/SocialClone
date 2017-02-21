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
    var isNewUser = false
    var loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
        feedTableView.delegate = self
        feedTableView.dataSource = self
        signOutBtn.imageView?.contentMode = .scaleAspectFit
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        loadingIndicator.center = feedTableView.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.startAnimating()
        self.view.addSubview(loadingIndicator)
        
        DataService.dataservice.REF_POST.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for data in snapshot {
                    if let postDic = data.value as? Dictionary<String, Any> {
                        let key = data.key
                        let post = Post(postKey: key, postData: postDic)
                        self.posts.insert(post, at: 0)
                    }
                }
                self.feedTableView.reloadData()
            }
        })
        
        if isNewUser {
            let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupID") as! PopUpVC
            self.addChildViewController(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            self.didMove(toParentViewController: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goImageVC" {
            if let indexPath = feedTableView.indexPathForSelectedRow{
                let destinationVC = segue.destination as! ImageVC
                destinationVC.post = self.posts[(indexPath as NSIndexPath).row]
            }
        }
    }
    @IBAction func tapImagePicker(_ sender: UIGestureRecognizer) {
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
                        self.loadingIndicator.startAnimating()
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        
        DataService.dataservice.REF_CURRENT_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? Dictionary<String,Any>
            let poster_name = value?["name"] as? String ?? ""
            let picture_Url = value?["picture_url"] as? String ?? ""
            let post : Dictionary<String, Any> = [
                "poster_name":poster_name,
                "picture_url":picture_Url,
                "caption": self.captionTextField.text!,
                "image_url": imgUrl,
                "likes": 0
            ]
            
            let firebasePost = DataService.dataservice.REF_POST.childByAutoId()
            firebasePost.setValue(post)
            
            //Post complete,clean UI
            self.captionTextField.text = ""
            self.addImage.image = UIImage(named: "add-image")
            self.imageIsSelected = false
            self.feedTableView.reloadData()
            self.loadingIndicator.stopAnimating()
        })
        
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? PostCell{
            loadingIndicator.stopAnimating()
            return cell
        } else {
            loadingIndicator.stopAnimating()
            return PostCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let postCell = cell as! PostCell
        
        if let image = FeedVC.imageCache.object(forKey: post.imageUrl as NSString), let profile = FeedVC.imageCache.object(forKey: post.picture_url as NSString) {
            postCell.configureCell(post: post, post_image: image, profile_image: profile)
        } else {
            print("first download img")
            postCell.configureCell(post: post)
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
            print("MARK: a valid image wasn't selected")
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
