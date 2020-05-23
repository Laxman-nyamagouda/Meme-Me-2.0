//
//  SecondViewController.swift
//  Meme Me 2.0
//
//  Created by Laxman Nyamagouda on 5/22/20.
//  Copyright © 2020 Laxman Nyamagouda. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController {

    //MARK: - Properties
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Sent Memes"
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 6) / 3, height: (UIScreen.main.bounds.width - 6) / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        
        //Add cancel button
        let btnAdd = UIBarButtonItem(barButtonSystemItem:.add, target: self, action: #selector(addMeme))
        self.navigationItem.rightBarButtonItem = btnAdd
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCollectionView(_:)), name: NSNotification.Name(rawValue: "reloadTableViewAndCollectionView"), object: nil)
    }

    //MARK: - handle notification
      @objc func updateCollectionView(_ notification: NSNotification) {

          collectionView.reloadData()
      }
    
    @objc func addMeme() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        let navController = UINavigationController(rootViewController: photoViewController)
        navigationController?.present(navController, animated: true, completion: nil)
    }

}

//MARK: - Extension
extension MemeCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        cell.memeImage.image = memes[indexPath.item].memedImage

        return cell
        
    }
    
}
