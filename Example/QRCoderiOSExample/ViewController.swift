//
//  ViewController.swift
//  QRCodeExampleiOS
//
//  Created by Sebastian Hunkeler on 27/04/15.
//  Copyright (c) 2015 Sebastian Hunkeler. All rights reserved.
//

import UIKit
import QRCoder

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let generator = QRCodeGenerator()
        imageView.image = generator.createImage(value: "Hello world!",size: CGSize(width: 200, height: 200))
    }

}

