//
//  ServiceClass.swift
//  ChatBox
//
//  Created by Naveen Kumar on 11/2/16.
//  Copyright © 2016 Naveen Kumar. All rights reserved.
//

import Foundation
import Alamofire

class ServiceClass:NSObject {
    static let SharedInstance = ServiceClass()
    
    func performLogin(userName:String, password:String, completion handler: @escaping (NSDictionary) -> Void) {
        let parameters:Parameters = ["email":userName, "password":password]
        
        Alamofire.request("http://ec2-54-166-14-133.compute-1.amazonaws.com/api/login", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary{
                handler(JSON)
            }
        }
    }
    
    func performSignUp(userFName:String, userLName:String, emailId:String, password:String, completion handler: @escaping (NSDictionary) -> Void) {
        let parameters:Parameters = ["fname":userFName, "lname":userLName, "email":emailId, "password":password]
        
        Alamofire.request("http://ec2-54-166-14-133.compute-1.amazonaws.com/api/signup", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary{
                handler(JSON)
            }
        }
    }
    
    func getMessages(token:String, completion handler: @escaping (NSDictionary) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "BEARER "+token
        ]
        
        Alamofire.request("http://ec2-54-166-14-133.compute-1.amazonaws.com/api/messages", headers: headers).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary{
                handler(JSON)
            }
        }
    }
    
    func getImageData(token:String, thumbnailID:String, completion handler: @escaping (Data) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "BEARER "+token
        ]
        
        let urlString = "http://ec2-54-166-14-133.compute-1.amazonaws.com/api/file/"+thumbnailID
        Alamofire.request(urlString, headers:headers).responseData{ response in
            if let JSON = response.result.value{
                handler(JSON)
            }
        }
    }
    
    func postMessageToServer(token:String, type:String, comment:String?, thumbnailID:String?, completion handler: @escaping (NSDictionary) -> Void)  {

        let parameters:Parameters = ["Type":type, "Comment":comment ?? "", "FileThumbnailId":thumbnailID ?? ""]
        
        let headers: HTTPHeaders = [
            "Authorization": "BEARER "+token
        ]
        
        Alamofire.request("http://ec2-54-166-14-133.compute-1.amazonaws.com/api/message/add", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary{
                handler(JSON)
            }
        }
    }
    
    func addImageFileToServer(token:String, imageData:Data, completion handler: @escaping (NSDictionary) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "BEARER "+token
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "newFile", fileName: "newFile.jpg", mimeType: "image/jpeg")
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: "http://ec2-54-166-14-133.compute-1.amazonaws.com/api/file/add", method: .post, headers: headers, encodingCompletion: { encodingResult in
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if let JSON = response.result.value as? NSDictionary{
                                handler(JSON)
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                }
        })
    }
}
