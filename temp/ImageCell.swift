//
//  ImageCell.swift
//  temp
//
//  Created by Samuel Germain on 2019-12-12.
//  Copyright © 2019 Sam G. All rights reserved.
//

import Foundation


//
//  ImageCell.swift
//  ImageGallery
//
//  Created by Samuel Germain on 2019-12-09.
//  Copyright © 2019 Sam G. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell{
    var url: URL?{
        didSet{
            self.fetchImage(withURL: url!)
        }
    }
    @IBOutlet var imageView: UIImageView!
    
    private func fetchImage(withURL url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let data = try? Data(contentsOf: url) else {
                return
            }
        
            guard let image = UIImage(data: data) else {
                print("Couldn't convert data to UIImage")
                print("The url is")
                print(url)
                return
            }
            
            // If by the time the async. fetch finishes, the imageURL is still the same, update the UI (in the main queue)
            if self?.url == url {
                print("teste")
                DispatchQueue.main.async {
                    print("testf")
                    self?.imageView.image = image
                }
            }
        }
    }
    
}
