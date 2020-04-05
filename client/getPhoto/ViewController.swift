//
//  ViewController.swift
//  getPhoto
//
//  Created by chegde on 9/15/19.
//  Copyright © 2019 chegde. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    var assetCount:Int = 0
    
    var startCount = 0
    var allPhotos : PHFetchResult<PHAsset>?
    
    var allVideos : PHFetchResult<PHAsset>?
    
    @IBOutlet var display: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        PHPhotoLibrary.requestAuthorization{(status) in
            switch status {
            case .authorized:
                
                let fetchOptions = PHFetchOptions()
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                self.assetCount = self.allPhotos!.countOfAssets(with: .image)
                
                self.readOne(indexNumber: 0)
                
                self.allVideos = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                //self.calcVideo();
                
            case .denied, .restricted:
                print("not allowed")
            case .notDetermined:
                print("not determined yet")
             
            default:
                print("other value")
            }
        }
        
        
        
    }
    
    
    
    func calcVideo() {
        print("video count", String(self.allVideos!.count))
        for didi in 1...(self.allVideos!.count-1) {
            print(didi)
            let video = self.allVideos!.object(at: didi)
            
            let pHVideoRequestOptions = PHVideoRequestOptions()
            
            PHImageManager().requestAVAsset(forVideo:video, options: pHVideoRequestOptions) { (avAsset: AVAsset?, aVAudioMix:AVAudioMix?, dict:[AnyHashable : Any]?) in
                
                for aa in avAsset!.commonMetadata {
                    if (aa.commonKey == AVMetadataKey.init("creationDate")) {
                        print(aa.stringValue)
                    }
                    
                }

            }
        }
    }
 
    func readOne(indexNumber: Int) {
        
        let a = self.allPhotos!.object(at: indexNumber)
        
        let pHImageRequestOptions = PHImageRequestOptions()
        
        PHImageManager().requestImageData(for: a, options: pHImageRequestOptions) {
            data,imageString,_,dict in
            
            var iData = data
            if (imageString == "public.heic") {
                let kk = UIImage(data: data!)
                
                iData = kk!.jpegData(compressionQuality: 1)
                
            }
            
            
            self.sendOne( data:iData!.base64EncodedData(),name:String(indexNumber))
            
        }
        
    }
    
    
    func tcpSendOne(dataString:Data,name:String) {
        
    }
    
    func getCurrentCount() {
        
        let url = URL(string: "http://10.0.0.107:6868/photo")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let existCountString = String(data: data, encoding: .utf8)
            let r = Int(existCountString!)
             self.readOne(indexNumber:r!)
            
        }
        
        task.resume()
    }
    
    // too large
    func sendOne(data:Data,name:String) {
        print("send one")
        let url = URL(string: "http://10.0.0.107:6868/photo?name=" + name)!
        var request = URLRequest(url: url)
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
      
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            let doneCount=Int(name)
            
            DispatchQueue.main.async {
                self.display.text = name + "照片备份完成\n" + self.display.text
            }
            
            
//            if (doneCount! < self.assetCount) {
//                self.readOne(indexNumber: doneCount!+1)
//            }
        }
        
        task.resume()
        
        
    }


}

