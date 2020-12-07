//
//  Song.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import Foundation

struct Song: Decodable{
    //TODO: check if we can change these names
    let id: String
    let name: String //title
    let artistName: String
    let artworkURL: String
    let artworkHeight: Int
    let artworkWidth: Int
    let duration: Int
    let uri: String
    
    init(id: String, name: String, artistName: String, artworkURL: String, artworkHeight: Int, artworkWidth: Int, duration: Int, uri: String){
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.artworkHeight = artworkHeight
        self.artworkWidth = artworkWidth
        self.duration = duration
        self.uri = uri
    }
}
