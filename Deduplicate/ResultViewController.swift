//
//  ResultViewController.swift
//  Deduplicate
//
//  Created by Xotech on 31/01/2024.
//

import UIKit

class ResultViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    var dedupImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        if let dedup =  dedupImage {
            imageView.image = dedup
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        if let buttonText = sender.titleLabel?.text {
            
            if buttonText == "Save Image"{
                if let dedup = dedupImage {
                    UIImageWriteToSavedPhotosAlbum(dedup, self, #selector(savedMessage(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            } else {
                performSegue(withIdentifier: "goBack", sender: self)
            }
           
        }
    }
    
    @objc func savedMessage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image to photo library:", error.localizedDescription)
        } else {
            saveButton.setTitle("Back", for: .normal)
            UIView.animate(withDuration: 2 ) {
                self.imageView.image = UIImage(named: "savedSuccess")
            }
           
            print("Image saved successfully to photo library")
        }
    }
    

}
