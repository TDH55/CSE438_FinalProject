//
//  GenrePickerVC.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 12/12/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit

class GenreCell: UITableViewCell{
    let apiManager = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.apiManager
    let selectImageConfig = UIImage.SymbolConfiguration(pointSize: 24.0)
    var genreName: String = ""
    var genrePickerVC: GenrePickerVC?
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var selectGenreButton: UIButton!

    
    //toggle if it is selectdd in the api manager and the ui
    @IBAction func SelectButtonClicked(_ sender: Any) {
        
        guard let apiManager = apiManager else { return }
        var genreIsSelected: Bool = apiManager.userGenres.contains(genreName)

        if(!genreIsSelected && apiManager.userGenres.count < 5){
            genreIsSelected = true
            //update image
            selectGenreButton.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: selectImageConfig), for: .normal)
            apiManager.userGenres.append(genreName)
            genrePickerVC?.doneButton.isEnabled = !apiManager.userGenres.isEmpty
        }else if (genreIsSelected){
            //deselect genre
            genreIsSelected = false
            selectGenreButton.setImage(UIImage(systemName: "circle", withConfiguration: selectImageConfig), for: .normal)
            
            if let index = apiManager.userGenres.firstIndex(of: genreName){
                apiManager.userGenres.remove(at: index)
            }
            genrePickerVC?.doneButton.isEnabled = !apiManager.userGenres.isEmpty
        }else if (apiManager.userGenres.count >= 5){
            //alert user too many genres
            let tooManyGenresAlert = UIAlertController(title: "Too many Genres Selected", message: "No more than 5 genres may be selected", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) {_ in
                tooManyGenresAlert.dismiss(animated: true, completion: nil)
            }
            
            tooManyGenresAlert.addAction(okAction)
            
            tooManyGenresAlert.show()
        }
        
    }
    
}

class GenrePickerVC: UIViewController {

    let apiManager = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.apiManager

    @IBOutlet weak var genreTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var genres: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.global(qos: .userInitiated).async {
            //get genre list and setup table view
            if let genreList = self.apiManager?.getGenres(){
                self.genres = genreList
            }
            DispatchQueue.main.async {
                self.genreTableView.dataSource = self
                self.genreTableView.delegate = self
                self.genreTableView.reloadData()
            }
        }
        
        //dont let user dismiss without setting genre
        self.isModalInPresentation = true
        
        if let apiManager = apiManager{
            doneButton.isEnabled = !apiManager.userGenres.isEmpty
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

    @IBAction func doneButton(_ sender: Any) {
        //send info to the api manager
        apiManager?.recommendationLock.signal()
        self.dismiss(animated: true, completion: nil)
    }

}




extension GenrePickerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectImageConfig = UIImage.SymbolConfiguration(pointSize: 24.0)

        let cell = genreTableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath) as! GenreCell
        
        cell.genreLabel.text = genres[indexPath.row]
        cell.genreName = genres[indexPath.row]
        cell.genrePickerVC = self
        
        guard let apiManager = apiManager else { return cell }
        if(apiManager.userGenres.contains(genres[indexPath.row])){
            cell.selectGenreButton.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: selectImageConfig), for: .normal)
        }else{
            cell.selectGenreButton.setImage(UIImage(systemName: "circle", withConfiguration: selectImageConfig), for: .normal)

        }
        
        return cell
    }
    
    
}

extension GenrePickerVC: UITableViewDelegate {
    
}
