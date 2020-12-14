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

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    var songID: String?
    var isLiked: Bool = false
    
    
    
    @IBOutlet weak var albumCoverButton: UIButton!
    
    //TODO: add button functionality and update the button display
    //TODO: add play/pause button? -> use the album art as play/pause?
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if(!isLiked){
            isLiked = true
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: thumbImageConfig), for: .normal)
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown", withConfiguration: thumbImageConfig), for: .normal)
            
            guard let songID = songID else { return }
            updateLiked(songID: songID, true)
        }
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        if(isLiked){
            isLiked = false
            likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: thumbImageConfig), for: .normal)
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: thumbImageConfig), for: .normal)
            
            //update core data
            guard let songID = songID else { return }
            updateLiked(songID: songID, false)
        }
    }
    
    
    @IBAction func imageTapped(_ sender: Any) {
//        NSURL *url = [NSURL URLWithString:@"https://open.spotify.com/album/0sNOF9WDwhWunNAHPD3Baj"];
//
        if let url  = URL(string: "https://open.spotify.com/track/\(songID!)"){
            print(url)
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
            }
        }
        print("tapped image")
    }
    
    
}

//MARK: View controller
class SongListVC: UIViewController {
    
    @IBOutlet weak var songTableView: UITableView!
    
    var songList: [NSManagedObject] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var homeVC: HomeViewController?
    
    var imageCache: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
        guard let thisViewControllerIndex = navigationController?.viewControllers.firstIndex(of: self) else { return }
        homeVC = navigationController?.viewControllers[thisViewControllerIndex - 1] as? HomeViewController
        
        songTableView.dataSource = self
        songTableView.delegate = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.getSongList()
            self.cacheImages()
            DispatchQueue.main.async {
                self.songTableView.reloadData()
            }
        }
    }
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        removeAllSongs()
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
        //set up table view cell
        let thumbImageConfig = UIImage.SymbolConfiguration(pointSize: 24.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongTableViewCell
        cell.songTitleLabel!.text = songList[indexPath.row].value(forKey: "name") as? String
        cell.songArtistLabel!.text = songList[indexPath.row].value(forKey: "artistName") as? String
        let image = imageCache[indexPath.row]
        cell.albumCoverButton.setTitle("", for: .normal)
        cell.albumCoverButton.setBackgroundImage(image, for: .normal)
        
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

    //delete from list and core data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            guard let homeVC = homeVC else { return }
            print("delete")
            //remove from likes in api manager
            if let songIndex = homeVC.apiManager?.likedSongs.firstIndex(of: songList[indexPath.row]){
                homeVC.apiManager?.likedSongs.remove(at: songIndex)
            }
            
            let commit = songList[indexPath.row]
            context.delete(commit)
            songList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do{
                try context.save()
            } catch let error {
                print("error deleting: \(error)")
            }
            
        }
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
        
    }
    
    //remove all songs from core data, empty all lists where they are included, and update table view
    func removeAllSongs(){
        guard let homeVC = homeVC else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SongResponse")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        } catch let error {
            print("error deleting: \(error)")
        }
        
        songList = []
        songTableView.reloadData()
//
        homeVC.apiManager?.songs = []
        homeVC.apiManager?.likedSongs = []
//        homeVC.songCardView.reloadData()
        homeVC.songCardView.reloadData()
        DispatchQueue.global(qos: .userInitiated).async {
            homeVC.apiManager?.getRecs(3)
            DispatchQueue.main.async {
                homeVC.songCardView.reloadData()
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func removeSong(id: String){
        
    }
}

//MARK: cell core data functions
extension SongTableViewCell {
    //udpate if song was liked or diliked
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


extension SongListVC {
    //get and add images to cache
    func cacheImages(){
        for song in songList {
            let lock = DispatchSemaphore(value: 0)
            var imageData: Data?
            let artworkURL = song.value(forKey: "artworkURL") as! String
            let url = URL(string:  artworkURL)!
            print(url)
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                print("url session")
                guard error == nil else { return }
                
                imageData = data
                lock.signal()
            }.resume()
            lock.wait()
            let image = UIImage(data: imageData!)!
            imageCache.append(image)
        }
    }
}
