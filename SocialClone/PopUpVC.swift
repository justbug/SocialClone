//
//  PopUpVC.swift
//  SocialClone
//
//  Created by Mark Chen on 2017/1/11.
//  Copyright © 2017年 Mark Chen. All rights reserved.
//

import UIKit
import FirebaseStorage
class PopUpVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nameTextField: FancyField!
    var imagePicker: UIImagePickerController!
    var imageIsSelected = false
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    func userDataUpdate(_ imgUrl: String){
            let user =
                [
                    "name":nameTextField.text!,
                    "picture_url": imgUrl
                    
                ]
        DataService.dataservice.REF_CURRENT_USER.updateChildValues(user)
    }
    
    @IBAction func tapAddImage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tapContinueBtn(_ sender: UIButton) {
        
        guard let img = addImage.image , imageIsSelected == true else {
            print("MARK: An image must selected")
            return
        }
        guard  let name = nameTextField.text, name != "" else {
            print("sdad")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = UUID().uuidString //create image unique id
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            DataService.dataservice.REF_USER_IMAGE.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print("MARK: Unable to upload image")
                } else {
                    print("MARK: Successfully upload image")
                    let downloadUrl = metaData?.downloadURL()?.absoluteString
                    if let imgUrl = downloadUrl {
                        self.userDataUpdate(imgUrl)
                    }
                }
            }
        }
        self.view.removeFromSuperview()
    }

}

// MARK: - UIImagePickerControllerDelegate
extension PopUpVC: UIImagePickerControllerDelegate {
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
