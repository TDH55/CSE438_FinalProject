//
//  APIResponse.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

//used https://crunchybagel.com/integrating-apple-music-into-your-ios-app/ for api help
//and used https://github.com/Rohan-cod/EmMusicPlayer/blob/main/EmMusicPlayer/Controller/AppleMusicAPI.swift

import Foundation

struct APIResponse: Decodable {
    let tracks: [Track]
    let seeds: [Seed]
}

struct GenreResponse: Decodable{
    let genres: [String]
}

struct PlaylistResponse: Decodable{
    let items: [Playlist]
}

struct Playlist: Decodable {
    let id: String
    let name: String
}

struct Track: Decodable {
    let id: String
    let album: Album
    let duration_ms: Int
    let uri: String
    let artists: [Artist]
    let name: String
}

struct Album: Decodable {
    let uri: String
    let artists: [Artist]
    let images: [AlbumImage]
    let id: String
    let name: String
    
}

struct Artist: Decodable {
    let name: String
    let type: String
    let uri: String
    let id: String
}

struct Seed: Decodable{
    let type: String
    let id: String
}

struct AlbumImage: Decodable{
    let url: String
    let width: Int
    let height: Int
}
