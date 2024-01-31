//
//  ResultViewController.swift
//  Deduplicate
//
//  Created by Xotech on 31/01/2024.
//

import UIKit

class ResultViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    var dedupImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dedup =  dedupImage {
            imageView.image = dedup
        }
    }
    


}
