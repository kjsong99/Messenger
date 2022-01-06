//
//  LaunchScreenViewController.swift
//  Messanger
//
//  Created by 송경진 on 2022/01/06.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var launchLogo : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.launchLogo.layer.cornerRadius = 20
    }
    

}
