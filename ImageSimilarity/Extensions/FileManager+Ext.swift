//
//  FileManager+Ext.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 7.10.2022.
//

import UIKit

extension FileManager {
    func copyImage(_ sourceUrl: URL) -> URL? {
        let imagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
        let dstURL = imagesFolder.appendingPathComponent("\(UUID().uuidString)_\(sourceUrl.lastPathComponent)")
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
    
    func imageUrls() -> [URL] {
        let imagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
        let fileURLs = try? contentsOfDirectory(at: imagesFolder, includingPropertiesForKeys: nil, options: [])
        return fileURLs ?? []
    }
}


