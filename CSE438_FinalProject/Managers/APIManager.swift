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

//TODO: make a singleton?

class APIManager{
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
//                    self?.displayError(error as NSError)
                    print(error)
                }
            }
        }
    }
    
    var userToken: String = ""
    
    var trackURI: String = ""
    var songs: [Song] = []
    
//    private func displayError(_ error: NSError?) {
//        if let error = error {
//            presentAlert(title: "Error", message: error.description)
//        }
//    }
    
    func connect() {
        appRemote?.authorizeAndPlayURI(trackURI)
//        appRemote?.connect()
    }
    
    func pause() {
        appRemote?.playerAPI?.pause(defaultCallback)
    }
    
    func play(){
        appRemote?.playerAPI?.play(trackURI, callback: defaultCallback)
    }
    
    func getCards() -> [Song] {
        print("get cards")
        appRemote?.contentAPI?.fetchRecommendedContentItems(forType: SPTAppRemoteContentTypeDefault, flattenContainers: true) {(items, error) in
//            guard error == nil else {
//                print(error)
////                return songs
//            }
            if let contentItems = items as? [SPTAppRemoteContentItem]{
                print(contentItems)
            }
//            print(result)
        }
        return songs
    }
    
    func getRecs() {
        print("getRecs")
        print(userToken)
        let lock = DispatchSemaphore(value: 0)
        let parameters: String = "limit=3&market=US&seed_artists=\("4NHQUGzhtTLFvgF5SZesLK")&seed_tracks=\("0c6xIDDpzE81m2q797ordA&m")" //TODO: fill parameters
        let recommendationURL = URL(string: "https://api.spotify.com/v1/recommendations?\(parameters)")!
        var recommendationRequest = URLRequest(url: recommendationURL)
        
        recommendationRequest.httpMethod = "GET"
        recommendationRequest.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        var apiResponse: APIResponse?
        
        URLSession.shared.dataTask(with: recommendationRequest) { (data, response, error) in
            print("url session")
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            do {
                guard data != nil else { return }
                apiResponse = try JSONDecoder().decode(APIResponse.self, from: data!)
                print(apiResponse!)
            }catch let error {
                print("error decoding api response: \(error)")
            }
            
            lock.signal()
        }.resume()
        
        lock.wait()
        return
    }
}
