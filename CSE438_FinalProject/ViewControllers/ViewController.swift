//
//  ViewController.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/16/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

//import UIKit
//import StoreKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//
//    let developerToken = "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgU2RjTpGkG0rvvAsXiatqlk2gu3s42RdXqVhrwAOXO26gCgYIKoZIzj0DAQehRANCAAQ9FyviDXNC7Q5VU8Zwp9iOmtxQB3jYkzv/8bo/Yj8stfJjjkg9Rva/oXOYKtw0JpVEOJwTT+fH8RQ4TlS1paO/"
//    let controller = SKCloudServiceController()
//    
//    //API help https://github.com/Rohan-cod/EmMusicPlayer/blob/54fd0a6789791ca4139c69ce610f2b1b68c74a3f/EmMusicPlayer/Controller/AppleMusicAPI.swift
//    //API helphttps://crunchybagel.com/integrating-apple-music-into-your-ios-app/
//    func getSongs(){
//        //usertoken is the thing that sets the app for the user
//        self.controller.requestUserToken(forDeveloperToken: developerToken) { (usertoken, error: Error?) in
//        
//            guard let token = usertoken else {
//                print("Error getting user token.")
//                return
//            }
//        }
//        //this part can be used multiple times for different sections of user data
//        //this is for songs in the user's library
//        let base = "https://api.music.apple.com/v1/me/library/"
//        let musicURL = URL(string: base+"songs")!
//        var musicRequest = URLRequest(url: musicURL)
//        musicRequest.httpMethod = "GET"
//        musicRequest.addValue("Bearer \(self.developerToken)", forHTTPHeaderField: "Authorization")
////        musicRequest.addValue(token, forHTTPHeaderField: "Music-User-Token")
//        
//        URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
//            guard error == nil else { return }
//            guard let data = data else {
//                print("Data not found")
//                return
//            }
//            //fetching and setting the JSON array
////            if let json = try? JSON(data: data) {
////                guard let results = (json["results"]["songs"]["data"]).array else {
////                    print("not able to fetch results")
////                    return
////                }
////                let result = results
////                for song in result {
////                    let attributes = song["attributes"]
////                    let currentSong = Song(id: attributes["playParams"]["id"].string!, name: attributes["name"].string!, artistName: attributes["artistName"].string!, artworkURL: attributes["artwork"]["url"].string!)
////                    songs.append(currentSong)
////                }
////                completion(songs)
////            } else {
////                completion(songs)
////            }
//        }.resume()
//        
//    }
////    func getGenres(){
////
////        self.controller.requestUserToken(forDeveloperToken: developerToken) { (usertoken, error: Error?) in
////
////            guard let token = usertoken else {
////                print("Error getting user token.")
////                return
////            }
////        }
////
////        let base = "https://api.music.apple.com/v1/me/library/"
////        let musicURL = URL(string: base+"/library/artists")!
////        var musicRequest = URLRequest(url: musicURL)
////        musicRequest.httpMethod = "GET"
////        musicRequest.addValue("Bearer \(self.developerToken)", forHTTPHeaderField: "Authorization")
////        musicRequest.addValue(token, forHTTPHeaderField: "Music-User-Token")
////
////    }
//}
//
