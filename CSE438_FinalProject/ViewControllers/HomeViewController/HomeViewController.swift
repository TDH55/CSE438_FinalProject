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
    
    @IBAction func dislikeButton(_ sender: Any) {
        //save song data (Core Data) so the song does not repeat
    }
    
    @IBAction func likeButton(_ sender: Any) {
        //from API, add song data to Table View in LikeListTableViewController() - maintain order
    }
    
    @IBAction func songListButton(_ sender: Any) {
        let songListVC = LikeListTableViewController()
        navigationController?.pushViewController(songListVC, animated: true)
    }
    
    @IBAction func lyricsButton(_ sender: Any) {
        let lyricsVC = LyricsViewController()
        navigationController?.pushViewController(lyricsVC, animated: true)
    }
    
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
