//
//  PhotoPicker.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 7.10.2022.
//


import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PHPickerViewController
    
    var selectionLimit: Int = 200
    var filter: PHPickerFilter?
    var itemProviders: [NSItemProvider] = []
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = self.selectionLimit
        configuration.filter = self.filter
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return PhotoPicker.Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
        
        var parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            var urls = [URL]()
            let myGroup = DispatchGroup()
            
            results.forEach { result in
                
                myGroup.enter()
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    if  reading as? UIImage != nil, error == nil {
                        
                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, _ in
                            if let url = url,
                               let dstUrl = FileManager.default.copyImage(url) {
                                print(dstUrl)
                                urls.append(dstUrl)
                                myGroup.leave()
                            }
                        }
                    }
                    
                }
            }
            
            myGroup.notify(queue: .main) {
                NotificationCenter.default.post(name: Notification.Name("imgURLs"), object: nil, userInfo: ["urls":urls])
            }
        }
    }
}

extension FileManager {
    func copyImage(_ sourceUrl: URL) -> URL? {
        let imagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
        let dstURL = imagesFolder.appendingPathComponent("\(sourceUrl.lastPathComponent)_\(UUID().uuidString)")
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            
            try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.copyItem(at: sourceUrl, to: dstURL)
            return dstURL
        } catch {
            print("Cannot copy item \(error)")
            return nil
        }
    }
}
