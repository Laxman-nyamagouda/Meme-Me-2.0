//
//  FirstViewController.swift
//  Meme Me 2.0
//
//  Created by Laxman Nyamagouda on 5/22/20.
//  Copyright © 2020 Laxman Nyamagouda. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Properties
    var btnEdit: UIBarButtonItem?
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    
    //MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Sent Memes"
        tableView.delegate = self
        tableView.dataSource = self
        
        //Add share button
        btnEdit = UIBarButtonItem(barButtonSystemItem:.edit, target: self, action: #selector(editMeme))
        self.navigationItem.leftBarButtonItem = btnEdit
        btnEdit?.isEnabled = true
        
        //Add cancel button
        let btnAdd = UIBarButtonItem(barButtonSystemItem:.add, target: self, action: #selector(addMeme))
        self.navigationItem.rightBarButtonItem = btnAdd
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableView(_:)), name: NSNotification.Name(rawValue: "reloadTableViewAndCollectionView"), object: nil)


    }

    // handle notification
    @objc func updateTableView(_ notification: NSNotification) {

        tableView.reloadData()
    }
    
    @objc func editMeme() {
        
    }

     @objc func addMeme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        let navController = UINavigationController(rootViewController: photoViewController)
        navigationController?.present(navController, animated: true, completion: nil)
    }
}

//MARK: - Extension
extension MemeTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MemeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell") as! MemeTableViewCell

        cell.memeImage.image = memes[indexPath.row].memedImage
        cell.title.text = "\(memes[indexPath.row].topText!)...\(memes[indexPath.row].bottomText!)".uppercased()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}
