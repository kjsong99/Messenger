//
//  PhotoViewerViewController.swift
//  Messanger
//
//  Created by 송경진 on 2022/01/06.
//

import UIKit
import SDWebImage
class PhotoViewerViewController: UIViewController {
    private let url: URL
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    init (with url: URL){
        self.url = url
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        navigationItem.largeTitleDisplayMode
        view.addSubview(imageView)
        self.imageView.sd_setImage(with: self.url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    

    
  
    


}
