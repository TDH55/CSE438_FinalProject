
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
    
//    var appRemote: SPTAppRemote? {
//        get {
//            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
//        }
//    }
    
    let apiManager = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.apiManager
//    let appRemote = apiManager.appRemote
//    var appRemote: SPTAppRemote?
    

    @IBOutlet weak var songCardView: KolodaView!
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.homeViewController = self
        
        guard apiManager != nil else { return }

        
        
        // Do any additional setup after loading the view.
        
        //TODO: Set up cards so these don't cause errors
        //set up card view
        songCardView.delegate = apiManager
        songCardView.dataSource = apiManager
        
        //TODO: load songs
        //request authorization for music api
        //setup apiManager - janky way because I couln't get DispatchSephamores to work
        //IMPORTANT!!! this is not a real implementation, we need to check for permission and ask if needed, and then load songs
        
        //TODO: check if authorized, and authorize user if they are not
        //if auth fails, retry
        
        DispatchQueue.main.async {
            self.apiManager!.connect()
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
