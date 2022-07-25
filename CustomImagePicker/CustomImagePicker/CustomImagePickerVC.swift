//
//  CustomImagePickerVC.swift
//  CustomImagePicker
//
//  Created by SOTSYS119 on 03/03/22.
//

import Foundation

import UIKit
import Photos

protocol CustomPickerViewDelegate {
    func getCustomPickerSelectedImage(_ image:  UIImage, _ avAsset: AVAsset?)
    func cancelCustomPickerSelectedImage()
}

class CustomImagePickerVC: UIViewController {
    fileprivate var collectionView: UICollectionView!
    fileprivate var collectionViewLayout: UICollectionViewFlowLayout!
    fileprivate var activityIndicator = UIActivityIndicatorView()
    
    fileprivate var assets: PHFetchResult<AnyObject>?
    fileprivate var sideSize: CGFloat!
    
    var delegate: CustomPickerViewDelegate?
    var mediaType: PHAssetMediaType = .image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //SET UP VIEW
        self.setupView()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        print("deallocated : ",classForCoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("allocated : ",classForCoder)
        
        self.getAssetsData()
    }
    
    fileprivate func getAssetsData(){
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            reloadAssets()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .authorized {
                    self.reloadAssets()
                } else {
                    self.showNeedAccessMessage()
                }
            })
        }
    }

    fileprivate func showNeedAccessMessage() {
        let alert = UIAlertController(title: "Image picker", message: "App need get access to photos", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func reloadAssets() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.assets = nil
            self.collectionView.reloadData()
            let option = PHFetchOptions()
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.assets = PHAsset.fetchAssets(with: self.mediaType, options: option) as? PHFetchResult<AnyObject>
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func setupView(){
        PHPhotoLibrary.shared().register(self)
        
        self.title = "Media"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        if #available(iOS 14, *) {
            let rightBar = UIBarButtonItem(title: "Select More",style: .plain, target: self,action: #selector(self.selectMoreAction))
            self.navigationItem.rightBarButtonItem = rightBar
        }
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.sideSize = ((self.view.bounds.width - 4) / 3)
        self.collectionViewLayout.itemSize = CGSize(width: self.sideSize, height: self.sideSize)
        self.collectionViewLayout.minimumLineSpacing = 2
        self.collectionViewLayout.minimumInteritemSpacing = 2
        
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: collectionViewLayout)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.register(ImagePickerCell.self, forCellWithReuseIdentifier: "ImagePickerCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        self.activityIndicator.tintColor = .gray
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
    }
    
    @objc func cancelAction() {
        self.delegate?.cancelCustomPickerSelectedImage()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectMoreAction() {
        // Show limited library picker
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        } else {
            // Fallback on earlier versions
        }
    }
}

extension CustomImagePickerVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assets != nil) ? assets!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let objPHAsset = assets?[indexPath.row] as! PHAsset
        if let cell = cell as? ImagePickerCell {
            cell.lblInfo.text = objPHAsset.duration.time
            cell.lblInfo.isHidden = self.mediaType == .video ? false : true
        }
        PHImageManager.default().requestImage(for: assets?[indexPath.row] as! PHAsset, targetSize: CGSize(width: sideSize, height: sideSize), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            if let cell = cell as? ImagePickerCell {
                cell.image = image
            }
        }
    }
    
}

extension CustomImagePickerVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let width = self.view.bounds.width
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImage(for: assets?[indexPath.row] as! PHAsset, targetSize: CGSize(width: width, height: 0.75 * width), contentMode: .aspectFill, options: options) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            if let _image = image {
                
                if self.mediaType == .video {
                    PHImageManager.default().requestAVAsset(forVideo: self.assets?[indexPath.row] as! PHAsset, options: nil) { (avAsset, avAudioMix, info) in
                        DispatchQueue.main.async {
                            print("Selected Image : \(_image)")
                            if let asset = avAsset as? AVURLAsset {
                                print("video url : \(asset.url)")
                                print(info as Any)
                                print(avAudioMix as Any)
                            }
                            self.delegate?.getCustomPickerSelectedImage(_image, avAsset)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }else{
                    print("Selected Image : \(_image)")
                    self.delegate?.getCustomPickerSelectedImage(_image, nil)
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
    
}

extension CustomImagePickerVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.getAssetsData()
    }
}


extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }

    private var seconds: Int {
        return Int(self) % 60
    }

    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }

    private var hours: Int {
        return Int(self) / 3600
    }

    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
    
    var time: String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

class ImagePickerCell: UICollectionViewCell {

    var imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .lightGray
        return img
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var lblInfo: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.clipsToBounds = true
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.lblInfo.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.lblInfo)
        // Set Image View
        self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set Info Label
        self.lblInfo.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        self.lblInfo.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.lblInfo.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.lblInfo.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


