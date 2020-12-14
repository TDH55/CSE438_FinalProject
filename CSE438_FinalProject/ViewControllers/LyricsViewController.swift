//
//  LyricsViewController.swift
//  CSE438_FinalProject
//
//  Created by Humza Siddiqui on 11/29/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class LyricsViewController: UIViewController {
    
    let apiManager = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.apiManager

    let geniusClientID = "7tRn4TXegPfIDVzpBoaryqrfyCc4c02LRq4l14_3kr3HQKoInWTI3hilEC53V9wp"
    let geniusClientAccessToken = "634wUzbOzN3aXtwZysKps7BdQILMvpvz5RtIgPSVSSVKFiOzYHLd3oVFrUtD9yA2"
    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var geniuseWebView: WKWebView!
    
    var songURL = "" {
        didSet {
            DispatchQueue.main.sync {
                guard let url = URL(string: songURL) else {
                    let alert = UIAlertController(title: "Lyrics not found", message: "We were not able to find lyrics for this song", preferredStyle: .alert)
                    
                    let dimsissAction = UIAlertAction(title: "OK", style: .default){ _ in
                        alert.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(dimsissAction)
                    alert.show()
                    return
                }
                let urlRequest = URLRequest(url: url)
                geniuseWebView.load(urlRequest)
                geniuseWebView.allowsBackForwardNavigationGestures = false
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        geniuseWebView.navigationDelegate = self
        navigationController?.navigationBar.isHidden = false
//        navigationController?.navigationItem.title = apiManager?.currentSong?.name
        guard let apiManager = apiManager, let currentSong = apiManager.currentSong else { return }
        apiManager.pause()
        navbar.title = "\(currentSong.name) - \(currentSong.artistName)"
        DispatchQueue.global(qos: .userInitiated).async {
            self.songURL = self.getLyrics(title: currentSong.name, artistName: currentSong.artistName)
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

//MARk: webview delgate
extension LyricsViewController: WKNavigationDelegate {
    
}

//MARK: Genius api functions
extension LyricsViewController {
    
    func getLyrics(title: String, artistName: String) -> String{
        let lock = DispatchSemaphore(value: 0)
        let baseURL = "https://api.genius.com/search"
        let query = "?q=\(title.replacingOccurrences(of: " ", with: "%20"))%20\(artistName.replacingOccurrences(of: " ", with: "%20"))"
        guard let requestURL = URL(string: baseURL + query) else {
            return ""
        }
        var request = URLRequest(url: requestURL)
        
        var returnURL = ""
        request.httpMethod = "GET"
        request.setValue("Bearer \(geniusClientAccessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            if let json = try? JSON(data: data!){
                for hit in json["response"]["hits"]{
                    if((hit.1["result"]["title"].string!.lowercased() == title.lowercased()) && (hit.1["result"]["primary_artist"]["name"].string!.lowercased() == artistName.lowercased())){
                        //dont touch these prints, for some reason it stops working when theyre gone
                        print(hit)
                        print(hit.1["result"]["url"])
                        guard let url = hit.1["result"]["url"].string else { return }
                        returnURL = url
                        break;
                    }
                }
                lock.signal()
            }
        }.resume()
        
        lock.wait()
        print("return")
        print(returnURL)
        return returnURL
    }
    
    
}
