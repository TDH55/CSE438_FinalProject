//
//  DataSource.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import Foundation
import Koloda


extension HomeViewController: KolodaViewDataSource{
    
    //var imageCache:[UIImage] = []
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        //TODO: create image cache? and give an image for the card here
        if apiManager?.currentSong?.artworkURL != nil {
            let url = (apiManager?.currentSong?.artworkURL)!
        let urlOne = URL(string:  url)
        let data = try? Data(contentsOf: urlOne!)
        let image = UIImage(data: data!)
            return UIImageView(image: image)
        } else {
        return UIImageView(image: UIImage(systemName: "star"))
        }
    }
    
    //TODO: create overlay for the card
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return songList.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    
}
