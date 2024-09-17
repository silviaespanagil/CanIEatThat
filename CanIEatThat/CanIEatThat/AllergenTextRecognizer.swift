//
//  AllergenTextRecognizer.swift
//  CanIEatThat
//
//  Created by Silvia España Gil on 17/9/24.
//

import Vision
import UIKit

class AllergenTextRecognizer {
    
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let fullText = recognizedStrings.joined(separator: " ")
            completion(fullText)
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? requestHandler.perform([request])
        }
    }
}
