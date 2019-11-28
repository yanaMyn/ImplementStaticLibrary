//
//  ViewController.swift
//  SingleProject
//
//  Created by yana mulyana on 16/10/19.
//  Copyright © 2019 LinkAja. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GamelanVision.shared.controller = self
        
    }
        
    func requestGet(){
        //customObject
        /*
        let url = "http://159.89.205.7:7008/v1.0/notification/notify"
        let header = [
            "msisdn": "082128583134",
            "limit": "10",
            "page": "0"
        ]
        */
        
        let url = "https://fakerestapi.azurewebsites.net/api/Users"
        
        GamelanVision.shared.request(url: url, method: .Get, encoding: .default, headers: nil, parameters: nil) { (response: DataResponse<[User]>) in
            guard let result = response.result else { return }
            switch result {
            case .success:
                print(response.object![0].Password)
                print(response.log!)
            case .failure:
                print(response.apiError as Any)
            }
        }
    }
    
    func requestPost() {
        let postUrl = "https://fakerestapi.azurewebsites.net/api/Users"
        
        let param: Parameters = [
            "ID": 1,
            "UserName": "dudung",
            "Password": "123"
        ]
        
        GamelanVision.shared.request(url: postUrl, method: .Post, encoding: .default, headers: nil, parameters: param) { (response: DataResponse<User>) in
            guard let result = response.result else { return }
            switch result {
            case .success:
                //print(response.object?.data?.pushStatus)
                print(response.object?.UserName as Any)
                print(response.log!)
            case .failure:
                print(response.apiError as Any)
            }
        }
        
    }
    @IBAction func getTapped(_ sender: Any) {
        self.requestGet()
    }
    
    @IBAction func postTapped(_ sender: Any) {
        self.requestPost()
    }
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadTapped(_ sender: Any) {
        let urlUpload = "http://localhost:8888/"
        let paramUpload = [
            "firstName"  : "yana",
            "lastName"    : "m",
            "userId"    : "9"
        ]
        
        let imageData = img.image!.jpegData(compressionQuality: 0.75)
        
        GamelanVision.shared.uploadFiles(url: urlUpload, headers: nil, parameters: paramUpload, data: imageData!) { (response: DataResponse<Upload>) in
            guard let result = response.result else { return }
            switch result {
            case .success:
                print(response.log!)
            case .failure:
                print(response.apiError as Any)
            }
        }
    }
    
    
    @IBAction func downloadTapped(_ sender: Any) {
        let urlDownload = "https://www.pexels.com/photo/2988535/download/?search_query=&tracking_id=4tj6kar59py"
        
        GamelanVision.shared.download(url: urlDownload)
    }
    
    @IBAction func pauseDwonload(_ sender: Any) {
        GamelanVision.shared.pause()
    }
    
    @IBAction func resumeDownload(_ sender: Any) {
        GamelanVision.shared.resumeDownload()
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.img.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: VisionDelegate {
    func didCompleteDownloaded(data: Data) {
        self.img.image = UIImage(data: data)
    }
    
    func progress(data: NSNumber) {
        self.progress.progress = Float(truncating: data)
        DispatchQueue.main.async {
            self.percentLabel.text = String(format: "%.0f", Float(truncating: data)*100) + "%"
        }
    }
}
