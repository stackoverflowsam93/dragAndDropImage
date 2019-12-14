//
//  ViewController.swift
//  ImageGallery
//
//  Created by Samuel Germain on 2019-12-09.
//  Copyright © 2019 Sam G. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController{

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var gallery = [(URL,Float)]()
    
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        
        switch(sender.state) {
        case .began:
                sender.scale = collectionView.zoomScale
        case .changed:
                collectionView.zoomScale = sender.scale
        case .failed, .ended:
                collectionView.collectionViewLayout.invalidateLayout()
        default:
            return
        }
    }
    
    private(set) lazy var cellWidth: CGFloat = collectionView.bounds.width / 3
    
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        (cell.url,_) = gallery[indexPath.item]
        return cell
    }
    
}

extension ImageViewController: UICollectionViewDropDelegate{

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .copy)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
 
        // Get the destion index path, if there's none set, just insert at the beginning
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)

        // Process all items being dragged
        for item in coordinator.items {

                // External drops must provide url and an image that we'll use to get an aspect-ratio
            var url: URL?
            var ratio: Float?
            
                // Get the URL
            item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                        // Is this a valid UIImage?
                if let image = provider as? UIImage {
                    // Get the aspect ratio of the image
                    ratio = Float(image.size.width / image.size.height)
                }
            }
                
            item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
                url = provider as? URL  //Check that url is valid
            
                // If both url and ratio were provided, perform the actual drop
                if url != nil && ratio != nil{
                    DispatchQueue.main.async {
                        collectionView.performBatchUpdates({
                            // Update model
                            self!.gallery.insert((url!.imageURL, ratio!), at: destinationIndexPath.item)

                            // Update view
                            collectionView.insertItems(at: [destinationIndexPath])

                            // Animates the item to the specified index path in the collection view.
                            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                        })
                    }
                }
            }
        }
    }
}



extension ImageViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cellWidth
        let (_,ratio) = gallery[indexPath.item]
        let height = Float(width) * ratio
        return CGSize(width: Int(width), height: Int(height))
    }
}
