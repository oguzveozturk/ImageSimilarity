//
//  UIImage+Ext.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 8.10.2022.
//

import UIKit

extension UIImage {
    func save() -> URL? {
        let imagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
        let dstURL = imagesFolder.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true, attributes: nil)
            try pngData()?.write(to: dstURL)
            return dstURL
        } catch {
            print("Cannot copy item \(error)")
            return nil
        }
    }
}
