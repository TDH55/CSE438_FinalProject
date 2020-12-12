//
//  SongListVC.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 11/29/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit
import CoreData

class SongTableViewCell: UITableViewCell {
    
    let thumbImageConfig = UIImage.SymbolConfiguration(pointSize: 24.0)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    var songID: String?
    var isLiked: Bool = false
    
    
    //TODO: add button functionality and update the button display
    //TODO: add play/pause button? -> use the album art as play/pause?
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if(!isLiked){
            isLiked = true
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: thumbImageConfig), for: .normal)
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown", withConfiguration: thumbImageConfig), for: .normal)
            
            //TODO: update core data
            guard let songID = songID else { return }
            updateLiked(songID: songID, true)
        }
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        if(isLiked){
            isLiked = false
            likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: thumbImageConfig), for: .normal)
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: thumbImageConfig), for: .normal)
            
            //TODO: update core data
            guard let songID = songID else { return }
            updateLiked(songID: songID, false)
        }
    }
    
}

class SongListVC: UIViewController {
    
    @IBOutlet weak var songTableView: UITableView!
    
    var songList: [NSManagedObject] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: dispatch queue
        songTableView.dataSource = self
        songTableView.delegate = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.getSongList()
            DispatchQueue.main.async {
                self.songTableView.reloadData()
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

//MARK: table view functions
extension SongListVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let thumbImageConfig = UIImage.SymbolConfiguration(pointSize: 24.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongTableViewCell
        cell.songTitleLabel!.text = songList[indexPath.row].value(forKey: "name") as? String
        cell.songArtistLabel!.text = songList[indexPath.row].value(forKey: "artistName") as? String
        
        cell.songID = songList[indexPath.row].value(forKey: "id") as? String
        
        cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: thumbImageConfig), for: .normal)
        cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown", withConfiguration: thumbImageConfig), for: .normal)
        
        if let isLiked = songList[indexPath.row].value(forKey: "liked") as? Bool {
            if isLiked {
                cell.isLiked = true
                cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: thumbImageConfig), for: .normal)
            }else{
//                cell.dislikeButton.imageView?.image = UIImage(named: "hand.thumbsdown.fill")
                cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: thumbImageConfig), for: .normal)
            }
        }
    
        return cell
    }
    
}

extension SongListVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
//    func tableView
}

//MARK: core data functions
extension SongListVC {
    func getSongList(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SongResponse")
        do{
            songList = try context.fetch(fetchRequest)
        } catch let error {
            print("Error fetching from core data \(error)")
        }
        
        //TODO: handle images if we want them on this screen
    }
    
}

//MARK: cell core data functions
extension SongTableViewCell {
    func updateLiked(songID: String, _ likeChangedTo: Bool) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SongResponse")
        fetchRequest.predicate = NSPredicate(format: "id == '\(songID)'")
        
        do{
            let result = try? context.fetch(fetchRequest)
            if let songToUpdate = result?.first {
                songToUpdate.setValue(likeChangedTo, forKey: "liked")
                try context.save()
            }
        } catch let error {
            print("error updating liked status: \(error)")
        }
    }
}
