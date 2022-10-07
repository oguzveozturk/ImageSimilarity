//
//  ContentViewModel.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 6.10.2022.
//

import Combine
import Vision

final class ContentViewModel:ObservableObject {
    var mixed = [Array(0...10)]
    var grouped = [[Int]]()
    
    init() {
        self.grouped = compare(analyze())
    }
    
    private func analyze() -> [(VNFeaturePrintObservation,Int)] {
        Array(0...10).map { (observationForImage(Bundle.main.url(forResource: "\($0)", withExtension: "jpg")!)!,$0) }
    }
    
    private func observationForImage(_ url: URL) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(url: url, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    
    private func compare(_ points:[(VNFeaturePrintObservation,Int)]) -> [[Int]] {
        guard !points.isEmpty else { return [] }
        var copyPoints = points
        
        var referencePhoto = copyPoints.first!
        var groupedIndexes = [[referencePhoto.1]]
        copyPoints.removeFirst()
        var i = 0
        
        while !copyPoints.isEmpty {
            var distance = Float(0)
            try? copyPoints[i].0.computeDistance(&distance, to: referencePhoto.0)
            let isLastLoop = i == copyPoints.count-1
            
            if distance == 0 {
                groupedIndexes[groupedIndexes.count-1].append(copyPoints[i].1)
                copyPoints.remove(at: i)
                if isLastLoop { reset() }
            } else {
                isLastLoop ? reset() : (i += 1)
            }
            print(groupedIndexes)
        }
        
        func reset() {
            referencePhoto = copyPoints.first!
            groupedIndexes.append([referencePhoto.1])
            copyPoints.removeFirst()
            i = 0
        }
        
        return groupedIndexes
    }
}
