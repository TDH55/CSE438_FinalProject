
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
import CoreData

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
    
    //core data setup
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //set default/initial values
    var userToken: String = ""
    var trackURI: String = ""
    var songs: [Song] = []
    var likedSongs: [NSManagedObject] = []

    
    var isPlaying: Bool = true

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
                    let song = Song(id: track.id, name: track.name, artistName: track.artists[0].name, artistID: track.artists[0].id, artworkURL: track.album.images[1].url, artworkHeight: track.album.images[1].height, artworkWidth: track.album.images[1].width, duration: track.duration_ms, uri: track.uri)
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
        //if less than 5 in core data, seeds equal those 5 (randomly by song or artist)
        //if more than 5, pick 5 songs weighting more recent higher, select song or artist as seed randomly
        
        let lock = DispatchSemaphore(value: 0)
        
        let parameters: String = "" //fill this with the seeds
        let recommendationURL = URL(string: "https://api.spotify.com/v1/recommendations?\(parameters)")!
        var recommendationRequest = URLRequest(url: recommendationURL)
        
        recommendationRequest.httpMethod = "GET"
        recommendationRequest.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        //variable for api response
        var apiResponse: APIResponse?
        
        //execute request
        URLSession.shared.dataTask(with: recommendationRequest) { (data, response, error) in
            guard error == nil else {
                print("error with reques: \(String(describing: error))")
                return
            }
            
            //try catch for processing response
            do {
                guard data != nil else { return }
                apiResponse = try JSONDecoder().decode(APIResponse.self, from: data!)
                for track in apiResponse!.tracks {
                    //create song onbject and add to array
                    let song = Song(id: track.id, name: track.name, artistName: track.artists[0].name, artistID: track.artists[0].id, artworkURL: track.album.images[1].url, artworkHeight: track.album.images[1].height, artworkWidth: track.album.images[1].width, duration: track.duration_ms, uri: track.uri)
                    self.songs.append(song)
                }
            } catch let error {
                print("error decoding api response \(error)")
            }
            
            lock.signal()
        }.resume()
        lock.wait()
        return
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
        //TODO: this will probably be replaced
        DispatchQueue.global(qos: .userInitiated).async {
            self.getRecs()
            DispatchQueue.main.async {
                koloda.reloadData()
            }
        }
//        getRecs()
//        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //TODO: asynchronously add a song to the back of the array everytip a card is swiped -> call getSingleRec()
        //TODO: add to likes/dislikes on swipe
        
        switch (direction){
        case .right:
//            print("right")
            AddResponse(song: songs[index], liked: true)
        case .left:
//            print("left")
            AddResponse(song: songs[index], liked: false)
        case .up:
            print("up")
        default:
            print("default")
        }
        
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        0.65
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        trackURI = songs[index].uri
        if isPlaying {
            appRemote?.playerAPI?.play(trackURI)
        }
    }
    
}

//core data functions
extension APIManager{
    func AddResponse(song: Song, liked: Bool){
        guard let entity = NSEntityDescription.entity(forEntityName: "SongResponse", in: context) else { return  }
        
        let songResponse = NSManagedObject(entity: entity, insertInto: context)
        
        //set values for song response
        songResponse.setValue(song.artistID, forKey: "artistID")
        songResponse.setValue(song.artistName, forKey: "artistName")
        songResponse.setValue(song.artworkHeight, forKey: "artworkHeight")
        songResponse.setValue(song.artworkURL, forKey: "artworkURL")
        songResponse.setValue(song.artworkWidth, forKey: "artworkWidth")
        songResponse.setValue(song.id, forKey: "id")
        songResponse.setValue(liked, forKey: "liked")
        songResponse.setValue(song.name, forKey: "name")
        songResponse.setValue(song.uri, forKey: "uri")
        
        if songResponse.value(forKey: "liked") as! Bool == true {
            likedSongs.append(songResponse)
            print("added to liked songs \(likedSongs.count)")
        }
        
        //try catch for persisting save
        do{
            try context.save()
        } catch let error {
            print("Failed saving to core data: \(error)")
        }
        return
    }
    
    
    func getLikedSongs(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SongResponse")
        fetchRequest.predicate = NSPredicate(format: "liked == \(true)")
        
        do{
            likedSongs = try context.fetch(fetchRequest)
        } catch let error {
            print("Error fetching from core data \(error)")
        }
    }
}
