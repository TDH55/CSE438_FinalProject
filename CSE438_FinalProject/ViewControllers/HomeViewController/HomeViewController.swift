//
//  HomeViewController.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit
import Koloda

class HomeViewController: UIViewController {
    
    @IBOutlet weak var songCardView: KolodaView!
    
    var songList: [Song] = []
    
   // Change
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set up card view
        songCardView.delegate = self
        songCardView.dataSource = self
        
        //TODO: load songs
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
