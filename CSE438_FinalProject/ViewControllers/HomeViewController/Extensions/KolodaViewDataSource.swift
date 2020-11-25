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
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        //TODO: create image cache? and give an image for the card here
        return UIImageView(image: UIImage(systemName: "star"))
    }
    
    //TODO: create overlay for the card
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
//    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return songList.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    
}
