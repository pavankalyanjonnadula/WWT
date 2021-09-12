//
//  ViewController.swift
//  Swifterviewing
//
//  Created by Tyler Thompson on 7/9/20.
//  Copyright © 2020 World Wide Technology Application Services. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var albumsTblView: UITableView!
    var albums:[Album] = []

    override func viewWillAppear(_ animated: Bool) {
        self.getAlbums()
    }
    
    func getAlbums(){
        SKProgressView.shared.showProgressView(self.view)

        API().getAlbums { (apiResult) in
            DispatchQueue.main.async {
                SKProgressView.shared.hideProgressView()

                switch apiResult{
                case .failure(let error) :
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    break
                case .success(let ressults) :
                    self.albums = ressults
                    self.albumsTblView.reloadData()
                }
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumcell", for: indexPath) as! AlbumsTableviewCell
        
        let albumAtIndex = albums[indexPath.row]
        cell.albumtitle.text = (albumAtIndex.title ?? "").lowercased().replacingOccurrences(of: "e", with: "")
        if let url = albumAtIndex.thumbnailUrl{
            cell.albumImage.loadImage(fromURL: url)
        }
        return cell
    }
}

//MARK: Cell Class

class AlbumsTableviewCell : UITableViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumtitle: UILabel!
    
}
