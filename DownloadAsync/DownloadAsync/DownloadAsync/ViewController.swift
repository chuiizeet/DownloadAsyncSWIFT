//
//  ViewController.swift
//  DownloadAsync
//
//  Created by Chuy on 17/12/17.
//  Copyright © 2017 Jegulabs. All rights reserved.
//

import UIKit
import Kingfisher

//Extension
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

struct Hero: Decodable{
    
    let localized_name: String
    let img: String
}

class ViewController: UIViewController, UICollectionViewDataSource {
   
    @IBOutlet weak var collectionView: UICollectionView!
    var heroes = [Hero]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DataSource
        collectionView.dataSource = self
        
        //MARK:: Download JSON
        
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
           
            if (error == nil){
                do {
                self.heroes =  try JSONDecoder().decode([Hero].self, from: data!)
                } catch {
                    print ("Parse Error")
                }
                
                DispatchQueue.main.async {
                    
                    self.collectionView.reloadData()
                }
            }
            
            
        }.resume()
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCell
        cell.nameLbl.text = heroes[indexPath.row].localized_name.capitalized
        
        //Image
        
        let defaultLink = "https://api.opendota.com"
        let completeLink = defaultLink + heroes[indexPath.row].img
        let urlImg = URL(string: completeLink)

        
        //cell.imageView.downloadedFrom(url: urlImg!)
        cell.imageView.kf.setImage(with: urlImg)
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = cell.imageView.frame.height / 2
        cell.imageView.contentMode = .scaleAspectFill

        return cell
        
    }
    

}

