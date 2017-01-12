//
//  Post.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/12/9.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import Foundation
import  Firebase
class Post {
    private var _picture_url:String!
    private var _poster_name:String!
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var picture_url: String {
        return _picture_url
    }
    
    var poster_name: String {
        return _poster_name
    }
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        if _imageUrl == nil {
            _imageUrl = ""
        }
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
//    init(caption: String, imageUrl: String, likes: Int) {
//        self._caption = caption
//        self._imageUrl = imageUrl
//        self._likes = likes
//    }
    
    init(postKey: String, postData: Dictionary<String,Any>) {
        self._postKey = postKey
        
        if let pictureUrl = postData["picture_url"] as? String {
            self._picture_url = pictureUrl
        }
        
        if let posterName = postData["poster_name"] as? String{
            self._poster_name = posterName
        }
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["image_url"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        _postRef = DataService.dataservice.REF_POST.child(_postKey)
    }
    
    func addLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
}
