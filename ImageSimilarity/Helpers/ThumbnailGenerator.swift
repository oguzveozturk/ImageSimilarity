//
//  ThumbnailGenerator.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 8.10.2022.
//

import QuickLookThumbnailing
import UIKit

struct ThumbnailGenerator {
    func thumbUrl(for imageUrl:URL,completion:@escaping (URL?) -> Void) {
        let request = QLThumbnailGenerator
            .Request(fileAt: imageUrl, size: CGSizeMake(200, 200), scale: UIScreen.main.scale,
                     representationTypes: .thumbnail)
        
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            if let thumbUrl = thumbnail?.uiImage.save() {
                try? FileManager.default.removeItem(at: imageUrl)
                completion(thumbUrl)
            } else {
                completion(nil)
            }
        }
    }
}
