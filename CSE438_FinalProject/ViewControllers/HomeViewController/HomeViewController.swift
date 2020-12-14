
//  HomeViewController.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/19/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit
import Koloda
import StoreKit
import MessageUI

class HomeViewController: UIViewController, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate {
    
    var phoneNumber:String = ""
    var recipients:[String] = []
    
    //https://www.twilio.com/blog/2018/07/sending-text-messages-from-your-ios-app-in-swift-using-mfmessagecomposeviewcontroller.html
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

        
        func showMessageInterface() {
            if MFMessageComposeViewController.canSendText() == true {
                       let messageController = MFMessageComposeViewController()
                        messageController.messageComposeDelegate  = self
                        //recipients.removeAll()
                        //recipients.append(phoneNumber)
                let currentSongName = apiManager?.currentSong?.name ?? "nil"
//                let currentArtist = apiManager?.currentSong?.artistName
                let currentID = apiManager?.currentSong?.id ?? nil
                print("Got here")
                if currentSongName != "nil" && currentID != nil {
                    let body = "Check out this new song I found through MusicMatch! It's called " + currentSongName + ", here's the Spotify link: https://open.spotify.com/track/\(currentID!)"
                    messageController.body = body
                    messageController.recipients = recipients
                    self.present(messageController, animated: true, completion: nil)
                }
                else {
                    print("Cant text")
                    return
                }
                   } else {
                       //handle text messaging not available
                       print("Cant text")
                   }
        }
    
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
        apiManager?.pause()
    }
    
    @IBAction func lyricsButton(_ sender: Any) {
    }
    
    @IBAction func shareButton(_ sender: Any) {
        //messageFriend
        showMessageInterface()
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
        apiManager?.rootViewController = self
        
        guard apiManager != nil else { return }
        
        
        
        // Do any additional setup after loading the view.
        
        //set up card view
        songCardView.delegate = apiManager
        songCardView.dataSource = apiManager
        
        //if auth fails, retry
        DispatchQueue.main.async {
            self.apiManager!.connect()
            self.apiManager?.getLikedSongs()
        }
        
        
        if apiManager?.isPlaying ?? false {
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playPauseImageConfig), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playPauseImageConfig), for: .normal)
        }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //navigationController?.navigationBar.isHidden = true
        guard let apiManager = apiManager else { return }
        if apiManager.isPlaying {
            apiManager.play()
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
