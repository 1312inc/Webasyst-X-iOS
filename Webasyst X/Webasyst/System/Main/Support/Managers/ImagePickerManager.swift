//
//  ImagePickerManager.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 21.11.2022.
//

import UIKit
import PhotosUI

public enum ImagePickerType {
//    case gallery
//    case camera
    case alert
}

public struct ImagePickerResponse {
    let image: UIImage
    let name: String
}

public class ImagePickerManager {
    
    static let shared = ImagePickerManager()
    private init() {}
    
    fileprivate var uiPicker = UIPicker()
//    fileprivate var phPicker = PHPicker()
    
    fileprivate var delegate: UIViewController!
    fileprivate lazy var alert: UIAlertController = {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: .getLocalizedString(withKey: "cameraEditScreen"), style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: .getLocalizedString(withKey: "galleryEditScreen"), style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: .getLocalizedString(withKey: "cancelEditScreen"), style: .cancel) { _ in })
        alert.view.tintColor = .appColor
        return alert
    }()
    
    // MARK: - Main method
    func pickImage(_ delegate: UIViewController, type: ImagePickerType = .alert, _ callback: @escaping (([ImagePickerResponse]) -> ())) {
        
        self.delegate = delegate
        
        self.uiPicker.setCallback(callback)
//        self.phPicker.setCallback(callback)
        
        switch type {
        case .alert:
            self.alert.popoverPresentationController?.sourceView = self.delegate!.view
            self.delegate.present(alert, animated: true, completion: nil)
//        case .gallery:
//            self.phPicker.presentPicker(from: delegate)
//        case .camera:
//            self.openCamera()
        }
    }
    
    fileprivate func openCamera() {
        
        alert.dismiss(animated: true, completion: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.uiPicker.setSourceType(.camera)
            self.uiPicker.presentPicker(from: self.delegate)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            delegate.present(alertController, animated: true)
        }
    }
    
    fileprivate func openGallery() {
        
        alert.dismiss(animated: true, completion: nil)
        
        self.uiPicker.setSourceType(.photoLibrary)
        self.uiPicker.presentPicker(from: self.delegate)
    }
}

//fileprivate final class PHPicker: PHPickerViewControllerDelegate {
//
//    fileprivate var pickImageCallback: (([ImagePickerResponse]) -> ())!
//
//    private func getPicker() -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .images
//        configuration.selectionLimit = 10
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        picker.view.tintColor = .appColor
//        return picker
//    }
//
//    func setCallback(_ callback: @escaping ([ImagePickerResponse]) -> ()) {
//        self.pickImageCallback = callback
//    }
//
//    func presentPicker(from vc: UIViewController) {
//        guard pickImageCallback != nil, !vc.isThere(PHPickerViewController.self) else { return }
//        vc.present(getPicker(), animated: true)
//    }
//
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//
//        picker.dismiss(animated: true)
//
//        var count = 0
//        var response: [ImagePickerResponse] = []
//
//        for result in results {
//            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
//
//                count += 1
//
//                if let image = object as? UIImage {
//                    let imageName = "RDV_" + UUID().uuidString + ".jpeg"
//                    response.append(ImagePickerResponse(image: image, name: imageName))
//                }
//
//                if count == results.count {
//                    self.pickImageCallback(response)
//                }
//            })
//        }
//    }
//}

fileprivate final class UIPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate var pickImageCallback: (([ImagePickerResponse]) -> ())!
    
    fileprivate lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.view.tintColor = .appColor
        picker.delegate = self
        return picker
    }()
    
    func setCallback(_ callback: @escaping ([ImagePickerResponse]) -> ()) {
        self.pickImageCallback = callback
    }
    
    func setSourceType(_ sourceType: UIImagePickerController.SourceType) {
        self.picker.sourceType = sourceType
    }
    
    func presentPicker(from vc: UIViewController) {
        guard self.pickImageCallback != nil, !vc.isThere(UIImagePickerController.self) else { return }
        vc.present(self.picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        var imageName = ""
        if let name = (info[.imageURL] as? URL)?.lastPathComponent {
            imageName = name
        } else {
            imageName = "RDV_" + UUID().uuidString + ".jpeg"
        }
        
        pickImageCallback([ImagePickerResponse(image: image, name: imageName)])
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
