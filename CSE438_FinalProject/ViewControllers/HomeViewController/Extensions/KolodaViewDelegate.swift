//
//  KolodaViewDelegate.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import Foundation
import Koloda

extension HomeViewController: KolodaViewDelegate{
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //TODO: get new songs
        songCardView.reloadData()
    }
    
    
}
