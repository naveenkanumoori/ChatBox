//
//  Message.swift
//  ChatBox
//
//  Created by Naveen Kumar on 11/2/16.
//  Copyright © 2016 Naveen Kumar. All rights reserved.
//

import Foundation

class Message: NSObject {
    
    private var userFname,userLname,fileThumbnailId,type,createdAt,comment:String?
    
    //Property Getters
    func getUserFName() -> String {
        return self.userFname!
    }
    func getUserLName() -> String {
        return self.userLname!
    }
    func getFileThumbnailId() -> String {
        return self.fileThumbnailId!
    }
    func getType() -> String {
        return self.type!
    }
    func getCreatedAt() -> String {
        return self.createdAt!
    }
    func getComment() -> String {
        return self.comment!
    }
    
    //Property Setters
    func setUserFName(userFname:String){
        self.userFname = userFname
    }
    func setUserLName(userLname:String){
        self.userLname = userLname
    }
    func setFileThumbnailId(fileThumbnailId:String){
        self.fileThumbnailId = fileThumbnailId
    }
    func setType(type:String){
        self.type = type
    }
    func setCreatedAt(createdAt:String){
        self.createdAt = createdAt
    }
    func setComment(comment:String){
        self.comment = comment
    }
}
