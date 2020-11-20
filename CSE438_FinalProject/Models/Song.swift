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
    
    init(id: String, name: String, artistName: String, artworkURL: String){
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkURL = artworkURL
    }
}
