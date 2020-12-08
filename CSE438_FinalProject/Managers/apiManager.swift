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

//TODO: set as kolada view data source?

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
                    print(error)
                }
            }
        }
    }
    
    var userToken: String = ""
    
    var trackURI: String = ""
    var songs: [Song] = []
    

    func connect() {
        appRemote?.authorizeAndPlayURI(trackURI)
    }
    
    func pause() {
        appRemote?.playerAPI?.pause(defaultCallback)
    }
    
    func play(){
        appRemote?.playerAPI?.play(trackURI, callback: defaultCallback)
    }
    
    
    func getRecs() {
        //TODO: if cordata is empty, execute random query, else set parameters based on 5 random songs/artists
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
                for track in apiResponse!.tracks {
                    //create song onbject and add to array
                    let song = Song(id: track.id, name: track.name, artistName: track.artists[0].name, artworkURL: track.album.images[1].url, artworkHeight: track.album.images[1].height, artworkWidth: track.album.images[1].width, duration: track.duration_ms, uri: track.uri)
                    self.songs.append(song)
                }
                print("songs \(self.songs), \(self.songs.count)")
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
