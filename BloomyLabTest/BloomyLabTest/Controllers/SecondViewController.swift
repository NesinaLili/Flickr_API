//
//  SecondViewController.swift
//  BloomyLabTest
//
//  Created by Лилия on 7/31/19.
//  Copyright © 2019 ITEA. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var imageViewDetail: UIImageView!
    
    var imageDetail = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewDetail.image = imageDetail

    }
    

}
