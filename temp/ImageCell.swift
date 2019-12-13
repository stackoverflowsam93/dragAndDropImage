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
            print("testx")
            self.fetchImage(withURL: url!)
        }
    }
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func fetchImage(withURL url: URL) {
        print("testy")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let data = try? Data(contentsOf: url) else {
                print("testz")
                return
            }
        
            guard let image = UIImage(data: data) else {
                print("Couldn't convert data to UIImage")
                print("The url is")
                print(url)
                return
            }
            print("testw")
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

extension URL {
    var imageURL: URL {
        if let url = UIImage.urlToStoreLocallyAsJPEG(named: self.path) {
            // this was created using UIImage.storeLocallyAsJPEG
            return url
        } else {
            // check to see if there is an embedded imgurl reference
            for query in query?.components(separatedBy: "&") ?? [] {
                let queryComponents = query.components(separatedBy: "=")
                if queryComponents.count == 2 {
                    if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                        return url
                    }
                }
            }
            return self.baseURL ?? self
        }
    }
}

extension UIImage
{
    private static let localImagesDirectory = "UIImage.storeLocallyAsJPEG"
    
    static func urlToStoreLocallyAsJPEG(named: String) -> URL? {
        var name = named
        let pathComponents = named.components(separatedBy: "/")
        if pathComponents.count > 1 {
            if pathComponents[pathComponents.count-2] == localImagesDirectory {
                name = pathComponents.last!
            } else {
                return nil
            }
        }
        if var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent(localImagesDirectory)
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                url = url.appendingPathComponent(name)
                if url.pathExtension != "jpg" {
                    url = url.appendingPathExtension("jpg")
                }
                return url
            } catch let error {
                print("UIImage.urlToStoreLocallyAsJPEG \(error)")
            }
        }
        return nil
    }
    
    func storeLocallyAsJPEG(named name: String) -> URL? {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            if let url = UIImage.urlToStoreLocallyAsJPEG(named: name) {
                do {
                    try imageData.write(to: url)
                    return url
                } catch let error {
                    print("UIImage.storeLocallyAsJPEG \(error)")
                }
            }
        }
        return nil
    }
}
