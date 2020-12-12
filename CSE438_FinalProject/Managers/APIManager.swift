
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


//TODO: add to a playlist
//TODO: initial recs

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
    
    var userID: String = ""

    //core data setup
    var rootViewController: UIViewController?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //set default/initial values
    var userToken: String = ""
    var trackURI: String = ""
    var songs: [Song] = []
    var likedSongs: [NSManagedObject] = []
    var responseIDs: [String] = []
    
    var userGenres: [String] = []
    
    var isPlaying: Bool = true

    let recommendationLock = DispatchSemaphore(value: 0)
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
    func getRecs(_ numberOfRecs: Int) {
        //TODO: if cordata is empty, execute random query, else set parameters based on 5 random songs/artists
        //TODO: we shoulp probably call this on a background thread
        //keeps function from returning before the request is complete
        var seedArtists: String = ""
        var seedTracks: String = ""
        var seedGenres: String = ""
        
        if(likedSongs.count == 0){
            DispatchQueue.main.sync {
                
                let genrePicker = GenrePickerVC()
                rootViewController?.performSegue(withIdentifier: "GenrePicker", sender: nil)
                genrePicker.isModalInPresentation = true
                
            }
            recommendationLock.wait()
            print("0 likes seeds")
            for genre in userGenres {
                if(seedGenres.isEmpty){
                    seedGenres.append(genre)
                }else{
                    seedGenres.append(",\(genre)")
                }
            }
        } else if(likedSongs.count < 3) {
            print(" < 3 likes seeds")
            for song in likedSongs {
                //add seed for artist and song
                if(seedArtists.isEmpty){
                    seedArtists.append(song.value(forKey: "artistID") as! String)
                }else {
                    seedArtists.append(",\(song.value(forKey: "artistID") as! String)")
                }
                
                if(seedTracks.isEmpty){
                    seedTracks.append(song.value(forKey: "id") as! String)
                }else{
                    seedTracks.append(",\(song.value(forKey: "id") as! String)")
                }
            }
        } else {
            print("normal seed case")
            //rng from 0 to count * 2
            var seedNumbers: [Int] = []
            
            while(seedNumbers.count < 5){
                let seedNumber = Int.random(in: 0..<likedSongs.count * 2)
                
                if !seedNumbers.contains(seedNumber) {
                    seedNumbers.append(seedNumber)
                }
            }
            
            for seedNumber in seedNumbers {
                let songNumber = seedNumber/2
                if (seedNumber % 2 == 0) {
                    //add track as seed
                    let trackID: String = likedSongs[songNumber].value(forKey: "id") as! String
                    if(seedTracks.isEmpty){
                        seedTracks.append(trackID)
                    }else{
                        //check if the seed is already in the string
                        if(!seedTracks.contains(trackID)){
                            seedTracks.append(",\(trackID)")
                        }
                    }
                } else {
                    //add artist as seed
                    let artistID: String = likedSongs[songNumber].value(forKey: "artistID") as! String
                    if(seedArtists.isEmpty){
                        seedArtists.append(artistID)
                    }else{
                        //check if the seed is already in the string
                        if(!seedArtists.contains(artistID)){
                            seedArtists.append(",\(artistID)")
                        }
                    }
                }
            }
        }
        
        let lock = DispatchSemaphore(value: 0)
        //set the url for the request
        var seedArtistParameter: String = ""
        var seedTracksParameter: String = ""
        var seedGenreParameter: String = ""
        
        if(!seedArtists.isEmpty){
            seedArtistParameter = "&seed_artists=\(seedArtists)"
        }
        if(!seedTracks.isEmpty){
            seedTracksParameter = "&seed_tracks=\(seedTracks)"
        }
        if(!seedGenres.isEmpty){
            seedGenreParameter = "&seed_genres=\(seedGenres)"
        }
        
        let parameters: String = "limit=\(numberOfRecs)&market=US\(seedArtistParameter)\(seedTracksParameter)\(seedGenreParameter)" //TODO: fill parameters
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
                    if(self.responseIDs.contains(track.id)){
                        //if the song has been reponded to, recursively call get recs until you get a song that hasnt been responded to
                        self.getRecs(1)
                    }else {
                        let song = Song(id: track.id, name: track.name, artistName: track.artists[0].name, artistID: track.artists[0].id, artworkURL: track.album.images[1].url, artworkHeight: track.album.images[1].height, artworkWidth: track.album.images[1].width, duration: track.duration_ms, uri: track.uri)
                        self.songs.append(song)
                    }
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
    
    func getGenres() -> [String] {
        let lock = DispatchSemaphore(value: 0)
        let requestURL = URL(string: "https://api.spotify.com/v1/recommendations/available-genre-seeds")!
        var genreRequest = URLRequest(url: requestURL)
        
        genreRequest.httpMethod = "GET"
        genreRequest.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        var apiResponse: GenreResponse?
        var genres: [String] = []
        URLSession.shared.dataTask(with: genreRequest) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            do {
                guard let data = data else { return }
                apiResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                if let response = apiResponse?.genres{
                    genres = response
                }
            }catch let error {
                print("error: \(error)")
            }
            lock.signal()
        }.resume()
        
        lock.wait()
        return genres
    }
    
    func getUserID() -> String {
        var returnValue: String = ""
        let lock = DispatchSemaphore(value: 0)
        let requestURL = URL(string: "https://api.spotify.com/v1/me")!
        var profileRequest = URLRequest(url: requestURL)
        
        profileRequest.httpMethod = "GET"
        profileRequest.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: profileRequest) {(data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            if let json = try? JSON(data: data!){
                returnValue = json["id"].string!
                lock.signal()
            }
        }.resume()
        
        lock.wait()
        return returnValue
    }
}

//MARK: KolodaViewDataSource
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

//MARK: KolodaViewDelegate
extension APIManager: KolodaViewDelegate{
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //TODO: get new songs
        //TODO: this will probably be replaced
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.getRecs(3)
//            DispatchQueue.main.async {
//                koloda.reloadData()
//            }
//        }
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getRecs(1)
            DispatchQueue.main.async {
                koloda.reloadData()
            }
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

//MARK: core data functions
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
//            print("added to liked songs \(likedSongs.count)")
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
    
    func getResponseIDs(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SongResponse")
        
        do {
            for song in try context.fetch(fetchRequest){
                let songID = song.value(forKey: "id") as! String
                responseIDs.append(songID)
            }
        } catch let error {
            print("Error fetching from core data \(error)")
        }
    }
}
