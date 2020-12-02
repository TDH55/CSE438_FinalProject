//
//  apiManager.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 12/1/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

//code adapted from https://www.appcoda.com/musickit-music-api/

import StoreKit
import SwiftyJSON


class apiManager{
    let developerToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlQ1M1NRTjU1NzkifQ.eyJpc3MiOiJCM1FYR0YyTjhZIiwiZXhwIjoxNjIyNjI0NTUxLCJpYXQiOjE2MDY4NjAxNTF9.wQT7V4REmD67PYHf99pXwP6OE7AVf_NjU75KfMwQIw747QHOM4my-228zfTXRINrtSB8uTb1_C6RM2D-h6Q0NA"
    let controller = SKCloudServiceController()
    var userToken: String?
    
//    init(userToken: String) {
//        self.userToken = userToken
//    }
    
//    func getUserToken() -> String{
//        print("getting user token")
//        var userToken = String()
//
//        //if this causes issues look into switching it to a dispatchque
//        let lock = DispatchSemaphore(value: 0)
//
//        //this is asynchronous, lock tells the thread to wait for a signal
////        SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken){ (recievedToken, error) in
////            print("request user token")
////            guard error == nil else {
////                print(error!.localizedDescription)
////                return
////            }
////            if let token = recievedToken{
////                userToken = token
////                lock.signal() //tells thread it can execute the rest of the code
////            }
////        }
//        let handler: (String?, Error?) -> Void = { (receivedToken, error) in
//            print("here")
//            lock.signal()
//        }
//
//        SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken, completionHandler: handler)
//
//
//
//
////
//        lock.wait() //wait for the signal before returning
//        print("this shouldn't print")
//        return userToken
//    }
    
    func getUserToken() -> String {
        var userToken = String()
     
        // 1
        let lock = DispatchSemaphore(value: 0)
     
        // 2
        controller.requestUserToken(forDeveloperToken: developerToken) { (receivedToken, error) in
            // 3
            print("kinda")
            guard error == nil else { return }
            if let token = receivedToken {
                userToken = token
                lock.signal()
            }
        }
     
        // 4
        lock.wait()
        return userToken
    }
    
    func fetchStorefrontID() -> String {
        
        guard userToken != nil else { return ""}
        
        let lock = DispatchSemaphore(value: 0)
        var storefrontID: String!
        
        let musicURL = URL(string: "https://api.music.apple.com/v1/me/storefront")!
        var musicRequest = URLRequest(url: musicURL)
        
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(userToken!, forHTTPHeaderField: "Music-User-Token")

        URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
            print("url session")
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            if let json = try? JSON(data: data!){
                print(json.rawString()!)
                //TODO: parse the json and lock.signal()
            }
        }.resume()
        
        lock.wait() //wait for the signal before returning the id
        return storefrontID
    }
    
}
