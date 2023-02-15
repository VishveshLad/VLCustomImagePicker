//
//  FileHelper.swift
//

import Foundation
import UIKit

public class FileHelper: NSObject {

    
    /// Copies a file to the documents directory.
    public class func copyFileURLToDocumentDirectory(_ documentURL: URL, overwrite: Bool) -> URL {
        // Copy file from original location to the Document directory (a location we can write to).
        let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newURL = docsFolder.appendingPathComponent(documentURL.lastPathComponent, isDirectory: false)
        let exists = FileManager.default.fileExists(atPath: newURL.path)
        if overwrite {
            do {
                try FileManager.default.removeItem(at: newURL)
            } catch CocoaError.fileNoSuchFile, CocoaError.fileReadNoSuchFile {
                // The file not existing doesn’t need reporting as an error since that’s what we want anyway.
            } catch {
                print("Error while removing file at \(newURL.path): \(error.localizedDescription)")
            }
        }

        if !exists || overwrite {
            do {
                try FileManager.default.copyItem(at: documentURL, to: newURL)
            } catch {
                print("Error while copying \(documentURL.path): \(error.localizedDescription)")
            }
        }

        return newURL
    }
    
    /// Copies a file to the documents directory.
    public class func copyFileURLToDocumentDirectoryToStoreOfflineDocument(_ documentURL: URL, overwrite: Bool) -> URL {
        // Copy file from original location to the Document directory (a location we can write to).
        let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let DirPath = docsFolder.appendingPathComponent("files")
        let newURL = docsFolder.appendingPathComponent(documentURL.lastPathComponent, isDirectory: false)
        let exists = FileManager.default.fileExists(atPath: newURL.path)
        if overwrite {
            do {
                try FileManager.default.removeItem(at: newURL)
            } catch CocoaError.fileNoSuchFile, CocoaError.fileReadNoSuchFile {
                // The file not existing doesn’t need reporting as an error since that’s what we want anyway.
            } catch {
                print("Error while removing file at \(newURL.path): \(error.localizedDescription)")
            }
        }

        if !exists || overwrite {
            do {
                try FileManager.default.copyItem(at: documentURL, to: newURL)
            } catch {
                print("Error while copying \(documentURL.path): \(error.localizedDescription)")
            }
        }

        return newURL
    }
    
    public class func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
        } catch {
            print(error)
        }
    }
    
    // FILE STOREGAE FLOW
    public class func getDocumentDirectorPathForFiles() -> URL? {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let DirPath = DocumentDirectory.appendingPathComponent("files")
        do
        {
            try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
        }
        return DirPath
    }
    
    public class func clearFilesDirectory() {
        do {
            guard let filesDirectory = FileHelper.getDocumentDirectorPathForFiles() else {
                return
            }
            let fileDirectoryData = try FileManager.default.contentsOfDirectory(atPath: filesDirectory.path)
            try fileDirectoryData.forEach { file in
                let fileUrl = filesDirectory.appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
        } catch {
            print(error)
        }
    }
    
    public class func getFileUrl(fileName: String) -> URL? {
        guard let signatureDirectory = FileHelper.getDocumentDirectorPathForFiles() else {
            return nil
        }
        let filePath = signatureDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            print(filePath)
            return filePath
        }else {
            return nil
        }
    }
    
    public class func removeFile(fileName: String) {
        guard let fileDirectory = FileHelper.getDocumentDirectorPathForFiles() else {
            return
        }
        let filePath = fileDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(atPath: filePath.path)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public class func removeFile(url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(atPath: url.path)
            }
        } catch {
            print(error)
        }
    }
    
    public class func saveImageToDocuments(image: UIImage, imageName: String) -> URL? {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tempDirectory.appendingPathComponent(imageName)
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("error saving file to documents:", error)
            }
        }
        return nil
    }
    
    public class func saveImageToDocumentDirAndGetSaveImage(image: UIImage, complete: @escaping (UIImage?)->()) {
        
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                     complete(UIImage(contentsOfFile: fileURL.path))
                }
            } catch {
                print("error saving file to documents:", error)
                complete(nil)
            }
        }else{
            complete(nil)
        }
    }
    
    public class func saveVideoToDocuments(videoURL: String, imageName: String) -> URL? {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tempDirectory.appendingPathComponent(imageName)
        
        if let url = URL(string: videoURL)  {
            do {
                if let data = try? Data(contentsOf: url) {
                    try data.write(to: fileURL)
                    return fileURL
                }
            } catch {
                print("error saving file to documents:", error)
            }
        }
        return nil
    }
    
    public class func saveVideoToDocuments(videoURL: String, complete: @escaping (URL?)->()){
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let originalFileName = URL(string: videoURL)?.lastPathComponent
        let formateDateName = "Video \(Int(Date().timeIntervalSince1970))"
        let strImageName = originalFileName ?? "\(formateDateName).mp4"
        let fileURL = tempDirectory.appendingPathComponent(strImageName)
        
        if let url = URL(string: videoURL)  {
            do {
                if let data = try? Data(contentsOf: url) {
                    try data.write(to: fileURL)
                    complete(fileURL)
                }
            } catch {
                print("error saving file to documents:", error)
                complete(nil)
            }
        }else{
            complete(nil)
        }
    }
    
    public class func saveImageToDocuments(imageURL: String, complete: @escaping (URL?)->()) {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let originalFileName = URL(string: imageURL)?.lastPathComponent.deletingPathExtension
        let formateDateName = "Photo \(Int(Date().timeIntervalSince1970))"
        let strImageName = "\(originalFileName ?? formateDateName).jpg"
        let fileURL = tempDirectory.appendingPathComponent(strImageName)
        
        if let url = URL(string: imageURL)  {
            do {
                let imgData = try Data(contentsOf: url)
                if let image = UIImage(data: imgData) {
                    if let data = image.jpegData(compressionQuality: 1.0) {
                        do {
                            try data.write(to: fileURL)
                            if FileManager.default.fileExists(atPath: fileURL.path) {
                                 complete(fileURL)
                            }
                        } catch {
                            print("error saving file to documents:", error)
                            complete(nil)
                        }
                    }else{
                        complete(nil)
                    }
                }else{
                    complete(nil)
                }
            }catch {
                print("error saving file to documents:", error)
                complete(nil)
            }
        }else{
            complete(nil)
        }
    }
    
    public class func renameFile(oldFileURL: URL, newFileName: String) -> URL? {
        let fileExtension = oldFileURL.pathExtension
        let oldName = oldFileURL.lastPathComponent.deletingPathExtension
        let filePath = oldFileURL.deletingLastPathComponent().path
    
        let newFilePathURL = URL(fileURLWithPath: filePath).appendingPathComponent(newFileName).appendingPathExtension(fileExtension)
        
        do {
            
            let originPath = oldFileURL.path
            if FileManager.default.fileExists(atPath: newFilePathURL.path) {
                self.removeFile(url: newFilePathURL)
            }
            
            try FileManager.default.moveItem(atPath: originPath, toPath: newFilePathURL.path)
            return newFilePathURL
        } catch {
            print(error)
            return nil
        }
    }
    
    // CACHE THUMBNAIL IMAGES
    // Get user's cache directory path
    public class func getCacheDirectoryPath() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
    }
    
    public class func storeImageIntoCacheDirectory(fileName: String, data: Data) {
        let cachesDirectoryUrl = self.getCacheDirectoryPath()
        let fileUrl = cachesDirectoryUrl.appendingPathComponent("\(fileName).jpg")
        let filePath = fileUrl.path
        FileManager.default.createFile(atPath: filePath, contents: data)
    }
    
    public class func storeImageIntoCacheDirectory(fileName: String, data: Data, complete: @escaping ((URL?)->())) {
        let cachesDirectoryUrl = self.getCacheDirectoryPath()
        let fileUrl = cachesDirectoryUrl.appendingPathComponent("\(fileName).jpg")
        let filePath = fileUrl.path
        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            try data.write(to: fileUrl)
            complete(fileUrl)
        }
        catch {
            print("error:", error)
            complete(nil)
        }
    }
}


