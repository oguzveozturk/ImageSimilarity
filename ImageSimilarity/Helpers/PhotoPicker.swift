//
//  PhotoPicker.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 7.10.2022.
//


import SwiftUI
import PhotosUI
import QuickLookThumbnailing

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
            var urls = [URL]() {
                didSet {
                    NotificationCenter.default.send(.indexes, "\(urls.count)/\(totalResult)")
                }
            }
            
            let phpGroup = DispatchGroup()
            
            let totalResult = results.count
            results.forEach { result in
                
                phpGroup.enter()
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    if  reading as? UIImage != nil, error == nil {
                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, _ in
                            if let url = url,
                               let imageUrl = FileManager.default.copyImage(url) {
                                
                                ThumbnailGenerator().thumbUrl(for: imageUrl) { thumbUrl in
                                    if let thumbUrl = thumbUrl {
                                        DispatchQueue.main.async { urls.append(thumbUrl) }
                                        phpGroup.leave()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            phpGroup.notify(queue: .main) {
                NotificationCenter.default.send(.imageURLs, urls)
                NotificationCenter.default.send(.indexes, "Add")
            }
        }
    }
}

