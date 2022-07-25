//
//  ViewController.swift
//  CustomImagePicker
//
//  Created by SOTSYS119 on 03/03/22.
//

import UIKit
import AVKit
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet weak var imgSelectedImage: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    
    let vc = AVPlayerViewController()
    var mediaType: PHAssetMediaType = .image
    var avAssetForVideo: AVAsset?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btnPlay.isHidden = true
        print(Bundle.main.executableURL!.lastPathComponent)
        let targetName = Bundle.main.executableURL!.lastPathComponent
        if targetName.hasSuffix("Video") {
            self.mediaType = .video
        }else{
            self.mediaType = .image
        }
    }


    @IBAction func btnOpenImagePicker_Clicked (_ sender: UIButton){
        let customPicker = CustomImagePickerVC()
        customPicker.delegate = self
        customPicker.mediaType = self.mediaType
        let navVC = UINavigationController(rootViewController: customPicker)
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func btnPlay_Clicked(_ sender: UIButton) {
        if let avAsset = self.avAssetForVideo as? AVURLAsset {
            let player = AVPlayer(url: avAsset.url)
            vc.player = player
            present(vc, animated: true) {
                self.vc.player?.play()
            }
        }
    }
}

extension ViewController: CustomPickerViewDelegate {
    
    func getCustomPickerSelectedImage(_ image: UIImage, _ avAsset: AVAsset?) {
        self.imgSelectedImage.image = image
        self.avAssetForVideo = avAsset
        
        if self.mediaType == .video && avAsset != nil{
            // show play button
            self.btnPlay.isHidden = false
        }else{
            // hide play button
            self.btnPlay.isHidden = true
        }
    }
    
    func cancelCustomPickerSelectedImage() {
        print("Cancel Custom picker clicked")
    }
}

