//
//  ViewController.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/11/21.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailTextField: FancyField!
    @IBOutlet weak var pwdTextField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        pwdTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    //MARK- dismiss textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
        return true
    }

}

