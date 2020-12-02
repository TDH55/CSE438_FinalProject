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
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            if let json = try? JSON(data: data!){
//                print(json.rawString()!)
                let result = (json["data"]).array!
                let id = (result[0].dictionaryValue)["id"]!
                
                storefrontID = id.stringValue
                lock.signal()
            }
        }.resume()
        
        lock.wait() //wait for the signal before returning the id
        return storefrontID
    }
    
    //TODO: implement music stuff
    
}
