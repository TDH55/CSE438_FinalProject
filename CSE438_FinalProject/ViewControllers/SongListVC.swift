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
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
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
//        songTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongTableViewCell
        cell.songTitleLabel!.text = songList[indexPath.row].value(forKey: "name") as? String
        cell.songArtistLabel!.text = songList[indexPath.row].value(forKey: "artistName") as? String
        
        if let isLiked = songList[indexPath.row].value(forKey: "liked") as? Bool {
            if isLiked {
                print("liked")
                cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            }else{
                print("disliked")
//                cell.dislikeButton.imageView?.image = UIImage(named: "hand.thumbsdown.fill")
                cell.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
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
