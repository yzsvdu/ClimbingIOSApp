//
//  GeneratedPathStepsCollectionViewController.swift
//  ClimbingAppIOSView
//
//  Created by Vincent Duong on 1/16/24.
//

import UIKit

private let reuseIdentifier = "Cell"

class GeneratedPathStepsCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("here")

        // Create a flow layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = collectionView.bounds.size
        flowLayout.sectionInset = UIEdgeInsets.zero

        // Set the layout for the collection view
        collectionView.collectionViewLayout = flowLayout

        // Enable paging and disable bouncing
        collectionView.isPagingEnabled = true
        collectionView.bounces = false

        // Register cell class
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           // Return the number of items you want
           return 5 // Replace with your actual number of items
       }

       override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

           // Configure the cell with dummy content
           cell.backgroundColor = UIColor.random() // Replace with your content configuration

           return cell
       }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
