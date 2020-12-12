//
//  SpotifySetup.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 12/12/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import Foundation

class SpotifyClient{
    let SpotifyClientID = "[your spotify client id here]"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    public func getConfiguration() -> SPTConfiguration{
        return configuration
    }
}

