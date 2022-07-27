# VLCustomImagePicker!

VLCustomImagePicker for limited permission. 

Here in view controller has on button click event



```

let customPicker = CustomImagePickerVC()
customPicker.delegate = self
customPicker.mediaType = self.mediaType
let navVC = UINavigationController(rootViewController: customPicker)
navVC.modalPresentationStyle = .overFullScreen
self.present(navVC, animated: true, completion: nil)

```


There has two app manage saprately one for image and one for video picker from photo gallery.

if you want to same app jsut you need change type 

```
var mediaType: PHAssetMediaType = .image

or

var mediaType: PHAssetMediaType = .video
```

if you like this please share give me some feedback. 
Thank you.

// HERE IS GIF FOR CUSTOM IMAGE PICKER.

Happy Coding..! :)

![](https://github.com/VishveshLad/VLCoustomImagePicker/blob/main/ezgif.com-gif-maker.gif)
