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
    
}

struct Artist: Decodable {
    
}

struct Seed: Decodable{
    
}
