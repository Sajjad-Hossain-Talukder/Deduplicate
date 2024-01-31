//
//  ViewController.swift
//  Deduplicate
//
//  Created by Xotech on 31/01/2024.
//

import UIKit
import PhotosUI
import CropViewController

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buttonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deduplicateButton: UIButton!
    
    @IBOutlet weak var showImageView: UICollectionView!
    @IBOutlet weak var showImageViewFlow: UICollectionViewFlowLayout!
    
    var flag : Bool = true
    var imageArray : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
        collectionControl()
    }
    
    func initSetting(){
        buttonViewHeight.constant  = contentView.layer.frame.height
        addButton.setTitle("Add Image", for: .normal)
        deduplicateButton.isEnabled = false
    }
    
    func collectionControl() {
        showImageView.register(UINib(nibName: "SelectedCell", bundle: nil), forCellWithReuseIdentifier: "SelectedCell")
        showImageView.collectionViewLayout = showImageViewFlow
        showImageView.showsVerticalScrollIndicator = false
        showImageViewFlow.minimumLineSpacing = 0
        showImageViewFlow.minimumInteritemSpacing = 0
    }

    @IBAction func addImage(_ sender: UIButton) {
        pickImage()
    }
    
    @IBAction func deDuplicate(_ sender: UIButton) {
        performSegue(withIdentifier: "goResult", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goResult" {
            let vc = segue.destination as! ResultViewController
        
            vc.dedupImage  = combineImagesVertically(imageArray)
        }
    }
    
    
    func controlView() {
        UIView.animate(withDuration: 0.5){
            if self.imageArray.count == 0 {
              
                self.buttonViewHeight.constant  = self.contentView.layer.frame.height
            }
            else {
                if self.imageArray.count == 1 {
                    self.addButton.setTitle("Add more Image", for: .normal)
                } else {
                    self.deduplicateButton.isEnabled = true
                }
                
                self.buttonViewHeight.constant  = self.contentView.layer.frame.height * 80 / 804
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func pickImage() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func cropImage(_ image : UIImage) {
        let cropView = CropViewController(croppingStyle: .default, image: image )
        cropView.aspectRatioPreset = .presetOriginal
        cropView.aspectRatioLockEnabled = false
        cropView.doneButtonTitle = "Selected"
        cropView.cancelButtonTitle = "Back"
        cropView.cancelButtonColor = UIColor.systemYellow
        cropView.delegate = self
        present(cropView,animated: true )
    }
    
    
    func combineImagesVertically(_ images: [UIImage]) -> UIImage? {
        
        var width : CGFloat = 0
        var height : CGFloat = 0
        var yPos  : CGFloat = 0
        
        for image in images {
            if (image.size.width > width ){
                width = image.size.width
            }
            height += image.size.height
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let combinedImage = renderer.image { context in
            for image in images {
                image.draw(at: CGPoint(x: 0, y: yPos))
                yPos += image.size.height
            }
        }
         

         return combinedImage
     }
     
}

extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedCell", for: indexPath) as! SelectedCell
        cell.imageView.image = imageArray[indexPath.row]
        
        return cell
    }
    
}


extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        print(imageArray[indexPath.row].size)
        
        
        return CGSize(width: collectionView.frame.width/2, height: collectionView.frame.height / 3 )
       }
    
}



extension ViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {
                 object,error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async { [self] in
                            self.cropImage(image)
                        }
                    }
            })
        }
    }
}


extension ViewController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("didCropToImage 1 ")
        imageArray.append(image)
        if imageArray.count >= 1 {
            controlView()
        }
        showImageView.reloadData()
        
        cropViewController.dismiss(animated: true)
    }
}

