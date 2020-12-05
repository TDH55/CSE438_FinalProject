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
        appRemote?.contentAPI?.fetchRecommendedContentItems(forType: "track", flattenContainers: true) {(result, error) in
            guard error == nil else { return }
            print(result)
        }
        return songs
    }
}
