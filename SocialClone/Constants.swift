//
//  Constants.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/11/22.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import UIKit

let SHADOW_GRAY: CGFloat = 120.0 / 255.0
let KEY_USER_ID = "uid"
enum InputError: String{
    case EmptyField = "電子郵件或密碼有一欄為空值"
    case EmailIsNotFormat = "電子郵件格式不正確"
    case PasswordIsNotFormat = "密碼不能少於6個字元"
}
