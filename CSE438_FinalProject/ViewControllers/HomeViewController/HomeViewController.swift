//
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
    let developerToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlQ1M1NRTjU1NzkifQ.eyJpc3MiOiJCM1FYR0YyTjhZIiwiZXhwIjoxNjIyNjI0NTUxLCJpYXQiOjE2MDY4NjAxNTF9.wQT7V4REmD67PYHf99pXwP6OE7AVf_NjU75KfMwQIw747QHOM4my-228zfTXRINrtSB8uTb1_C6RM2D-h6Q0NA"

    @IBOutlet weak var songCardView: KolodaView!
    
    var songList: [Song] = []
    
    @IBAction func dislikeButton(_ sender: Any) {
        //save song data (Core Data) so the song does not repeat
    }
    
    @IBAction func likeButton(_ sender: Any) {
        //from API, add song data to Table View in LikeListTableViewController() - maintain order
    }
    
    @IBAction func songListButton(_ sender: Any) {
//        let songListVC = SongListVC()
//        navigationController?.pushViewController(songListVC, animated: true)
    }
    
    @IBAction func lyricsButton(_ sender: Any) {
//        let lyricsVC = LyricsViewController()
//        navigationController?.pushViewController(lyricsVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set up card view
//        songCardView.delegate = self
//        songCardView.dataSource = self
        
        //TODO: load songs
        //request authorization for music api
        //setup apiManager - janky way because I couln't get DispatchSephamores to work
        let thisApiManger =  apiManager()
        var userToken = String()
        SKCloudServiceController().requestUserToken(forDeveloperToken: developerToken){ (recievedToken, error) in
            print("request user token")
            guard error == nil else {
                print(error)
                print("error")
                return
            }
            if let token = recievedToken{
                userToken = token
//                lock.signal() //tells thread it can execute the rest of the code
                thisApiManger.userToken = userToken
                print(userToken)
                thisApiManger.fetchStorefrontID()
//                lock.signal()
            }
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
