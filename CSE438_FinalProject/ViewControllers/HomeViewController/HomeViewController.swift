
//  HomeViewController.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit
import Koloda
import StoreKit

class HomeViewController: UIViewController {
    
    let apiManager = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.apiManager
    
    let playPauseImageConfig = UIImage.SymbolConfiguration(pointSize: 32.0)
    

    @IBOutlet weak var songCardView: KolodaView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    var songList: [Song] = []
    
    @IBAction func dislikeButton(_ sender: Any) {
        //save song data (Core Data) so the song does not repeat
        songCardView.swipe(.left)
    }
    
    @IBAction func likeButton(_ sender: Any) {
        //from API, add song data to Table View in LikeListTableViewController() - maintain order
        songCardView.swipe(.right)
    }
    
    @IBAction func songListButton(_ sender: Any) {
//        let songListVC = SongListVC()
//        navigationController?.pushViewController(songListVC, animated: true)
        
    }
    
    //TODO: Somethings wrong here when running on device - could be a storyboard issue
    @IBAction func lyricsButton(_ sender: Any) {
//        let lyricsVC = LyricsViewController()
//        navigationController?.pushViewController(lyricsVC, animated: true)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        //play/pause the current song
        if apiManager?.isPlaying ?? false {
            apiManager?.pause()
            apiManager?.isPlaying = false
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playPauseImageConfig), for: .normal)
        } else{
            apiManager?.play()
            apiManager?.isPlaying = true
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playPauseImageConfig), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.homeViewController = self
        
        guard apiManager != nil else { return }
        
        
        
        // Do any additional setup after loading the view.
        
        //set up card view
        songCardView.delegate = apiManager
        songCardView.dataSource = apiManager
        
        //IMPORTANT!!! this is not a real implementation, we need to check for permission and ask if needed, and then load songs
        //TODO: check if authorized, and authorize user if they are not
        //if auth fails, retry
        DispatchQueue.main.async {
            self.apiManager!.connect()
//            self.apiManager?.getLikedSongs()
        }
        
        
        if apiManager?.isPlaying ?? false {
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playPauseImageConfig), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playPauseImageConfig), for: .normal)
        }

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
