
//  apiManager.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 12/1/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//
//code adapted from https://www.appcoda.com/musickit-music-api/
import StoreKit
import SwiftyJSON
import Koloda

//TODO: set as kolada view data source?
class APIManager{
        
    //sets tha ppRemote to what was defined in scene delegate
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    //spotify setup stuff
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    //TODO: I did this to silence a warning. It needs to be fixed because it is gross
                    print(self ?? "")
                    print(error)
                }
            }
        }
    }
    
    //set default/initial values
    var userToken: String = ""
    var trackURI: String = ""
    var songs: [Song] = []
    

    func connect() {
        appRemote?.authorizeAndPlayURI(trackURI)
    }
    
    func pause() {
        //pause playback
        appRemote?.playerAPI?.pause(defaultCallback)
    }
    
    func play(){
        //continue playing current song
        appRemote?.playerAPI?.play(trackURI, callback: defaultCallback)
    }
    
    
    //use this to get the initial recs upon login
    func getRecs() {
        //TODO: if cordata is empty, execute random query, else set parameters based on 5 random songs/artists
        //TODO: we shoulp probably call this on a background thread
        //keeps function from returning before the request is complete
        let lock = DispatchSemaphore(value: 0)
        //set the url for the request
        let parameters: String = "limit=3&market=US&seed_artists=\("4NHQUGzhtTLFvgF5SZesLK")&seed_tracks=\("0c6xIDDpzE81m2q797ordA&m")" //TODO: fill parameters
        let recommendationURL = URL(string: "https://api.spotify.com/v1/recommendations?\(parameters)")!
        var recommendationRequest = URLRequest(url: recommendationURL)
        
        //setup the http request
        recommendationRequest.httpMethod = "GET"
        recommendationRequest.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        //variable for api response
        var apiResponse: APIResponse?
        
        //execute the api request
        URLSession.shared.dataTask(with: recommendationRequest) { (data, response, error) in
            //print error and return if there is an error
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            //try catch for putting api response into our defined struct (APIResponse)
            do {
                guard data != nil else { return }
                apiResponse = try JSONDecoder().decode(APIResponse.self, from: data!)
                for track in apiResponse!.tracks {
                    //create song onbject and add to array
                    let song = Song(id: track.id, name: track.name, artistName: track.artists[0].name, artworkURL: track.album.images[1].url, artworkHeight: track.album.images[1].height, artworkWidth: track.album.images[1].width, duration: track.duration_ms, uri: track.uri)
                    self.songs.append(song)
                }
            }catch let error {
                print("error decoding api response: \(error)")
            }
            //signal that the function can return
            lock.signal()
        }.resume()
        
        //wait for the signal before returning
        lock.wait()
        return
    }
    
    //use this to get a single rec on swipe
    func getSingleRec(){
        //TODO: implement method to get single rec and add it to array
    }
}

extension APIManager: KolodaViewDataSource{
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
            //TODO: create image cache? and give an image for the card here
        return UIImageView(image: UIImage(systemName: "star"))
    }
    
        //TODO: create overlay for the card
    //    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
    //        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    //    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return songs.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
}

extension APIManager: KolodaViewDelegate{
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //TODO: get new songs
        getRecs()
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        print(songs[index])
        //TODO: asynchronously add a song to the back of the array everytip a card is swiped
        //TODO: add to likes/dislikes on swipe
        
        switch (direction){
        case .right:
            print("right")
        case .left:
            print("left")
        case .up:
            print("up")
        default:
            print("default")
        }
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        0.65
    }
    
    
}
