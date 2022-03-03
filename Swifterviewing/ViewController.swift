//
//  ViewController.swift
//  Swifterviewing
//
//  Created by Tyler Thompson on 7/9/20.
//  Copyright © 2020 World Wide Technology Application Services. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var albums:[Album] = []
    let api : API = API()
    @IBOutlet weak var albumTableView: UITableView!
    
    let kCellIdentifier = "AlbumCell"
    let kRowHeight = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    func createUI() {
        albumTableView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        albumTableView.rowHeight = UITableView.automaticDimension
        albumTableView.estimatedRowHeight = kRowHeight;
        let refreshcontrol = UIRefreshControl()
        refreshcontrol.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        albumTableView.refreshControl = refreshcontrol
    }
    
    @objc func refreshData() {
        albumTableView.refreshControl?.beginRefreshing()
        api.getAlbums { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let albums):
                    self?.albums = albums.map { album in
                        var newAlbum = album
                        // removing all occurances of the letter "e"
                        newAlbum.title = album.title.replacingOccurrences(of: "e", with: "")
                        return newAlbum
                    }
                    self?.albumTableView.reloadData()
                case .failure(let error):
                    print("Fetching with \(error)")
                }
                self?.albumTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! AlbumCell
        let album = albums[indexPath.row]
        cell.titleLabel?.text = album.title
        cell.albumImageView?.image = UIImage(systemName: "person.crop.circle")
        api.getImageForPath(imagePath: album.thumbnailUrl) { image in
            DispatchQueue.main.async {
                cell.albumImageView?.image = nil
                cell.albumImageView?.image = image
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        <#code#>
    //    }
}
