//
//  ContentViewModel.swift
//  ImageSimilarity
//
//  Created by Oğuz Öztürk on 6.10.2022.
//

import Combine
import Vision

@MainActor
final class ContentViewModel:ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    
    var stockUrls = [Array(0...10).compactMap { (Bundle.main.url(forResource: "\($0)", withExtension: "jpg")) }]
    var groupedUrls = [[URL]]()
        
    init() {
        self.groupedUrls = compare(analyze(urls: stockUrls.first!))
        
        NotificationCenter.default.publisher(for: Notification.Name("imgURLs"))
            .sink { [weak self] notif in
            if let urls = notif.userInfo?["urls"] as? [URL] {
                self?.addPhoto(urls: urls)
            }
        }.store(in: &cancellable)
    }
    
    func addPhoto(urls:[URL]) {
        stockUrls[0].append(contentsOf: urls)
        objectWillChange.send()
        groupedUrls = compare(analyze(urls: stockUrls.first!))
    }
    
    private func analyze(urls:[URL]) -> [ImageObservation] {
        urls.compactMap { [weak self] url in
            if let self = self, let observation = self.observationForImage(url) {
                return ImageObservation(url: url, observation: observation)
            }
            return nil
        }
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
    
    private func compare(_ points:[ImageObservation]) -> [[URL]] {
        guard !points.isEmpty else { return [] }
        var copyPoints = points
        
        var referencePhoto = copyPoints.first!
        var groupedURLs = [[referencePhoto.url]]
        copyPoints.removeFirst()
        var i = 0
        
        while !copyPoints.isEmpty {
            var distance = Float(0)
            try? copyPoints[i].observation.computeDistance(&distance, to: referencePhoto.observation)
            let isLastLoop = i == copyPoints.count-1
            
            if distance < 14 {
                groupedURLs[groupedURLs.count-1].append(copyPoints[i].url)
                copyPoints.remove(at: i)
                if isLastLoop { reset() }
            } else {
                isLastLoop ? reset() : (i += 1)
            }
        }
        
        func reset() {
            referencePhoto = copyPoints.first!
            groupedURLs.append([referencePhoto.url])
            copyPoints.removeFirst()
            i = 0
        }
        
        return groupedURLs
    }
}
