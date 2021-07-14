//
//  ImagesViewController.swift
//  pushnotification
//
//  Created by Vu Minh Tam on 7/8/21.
//

import UIKit

class ImagesViewController: UIViewController {

    @IBOutlet weak var clollectionView: UICollectionView!
    
    var arrURLs = [
        "https://homepages.cae.wisc.edu/~ece533/images/airplane.png",
        "https://homepages.cae.wisc.edu/~ece533/images/arctichare.png",
        "https://homepages.cae.wisc.edu/~ece533/images/baboon.png",
        "https://homepages.cae.wisc.edu/~ece533/images/barbara.png",
        "https://homepages.cae.wisc.edu/~ece533/images/boat.png",
        "https://homepages.cae.wisc.edu/~ece533/images/cat.png",
        "https://homepages.cae.wisc.edu/~ece533/images/fruits.png",
        "https://homepages.cae.wisc.edu/~ece533/images/frymire.png",
        "https://homepages.cae.wisc.edu/~ece533/images/girl.png",
        "https://homepages.cae.wisc.edu/~ece533/images/goldhill.png",
        "https://homepages.cae.wisc.edu/~ece533/images/lena.png",
        "https://homepages.cae.wisc.edu/~ece533/images/monarch.png",
        "https://homepages.cae.wisc.edu/~ece533/images/mountain.png",
        "https://homepages.cae.wisc.edu/~ece533/images/peppers.png",
        "https://homepages.cae.wisc.edu/~ece533/images/pool.png",
        "https://homepages.cae.wisc.edu/~ece533/images/sails.png",
        "https://homepages.cae.wisc.edu/~ece533/images/serrano.png",
        "https://homepages.cae.wisc.edu/~ece533/images/tulips.png",
        "https://homepages.cae.wisc.edu/~ece533/images/watch.png",
        "https://homepages.cae.wisc.edu/~ece533/images/zelda.png"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        clollectionView.delegate = self
        clollectionView.dataSource = self

    }

}

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let w = self.view.bounds.width - 30

            return CGSize(width: w, height: w + 60)
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath) as! ImagesCell

                let str = arrURLs[indexPath.item]
                let url = URL(string: str)

        DispatchQueue.main.async {
            
        }

                return cell
    }
    
    
}
