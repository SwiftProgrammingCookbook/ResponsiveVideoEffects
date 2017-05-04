//
//  ViewController.swift
//  ResponsiveVideoEffects
//
//  Created by Keith Moon on 03/05/2017.
//  Copyright © 2017 Keith Moon. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var export: AVAssetExportSession?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let now = Date()
        
        let videoURL = Bundle.main.url(forResource: "Video1", withExtension: "mov", subdirectory: "Videos")!
        let videoAsset = AVAsset(url: videoURL)
        
        
//        let filter = CIFilter(name: "CIVibrance")!
        let composition = AVVideoComposition(asset: videoAsset, applyingCIFiltersWithHandler: { request in
            
            
            // Clamp to avoid effecting transparent pixels at the image edges
            var source = request.sourceImage.clampingToExtent()
            
            source = source.applyingFilter("CIVibrance", withInputParameters: ["inputAmount": 8.0])
//            source = source.applyingFilter("CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: 100])
            request.finish(with: source, context: nil)
            
            
//            filter.setValue(source, forKey: kCIInputImageKey)
//            
//            // Amount
//            filter.setValue(NSNumber(value: 5.0), forKey: "inputAmount")
//            
//            // Crop the effected output to the bounds of the original image
//            let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
//            
//            // Provide the filter output to the composition
//            request.finish(with: output, context: nil)
        })
        
        let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let docsURL = URL(fileURLWithPath: docsPath)
        let outputURL = docsURL.appendingPathComponent("video2.mov", isDirectory: false)
        
        
        let export = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPreset1280x720)!
        export.outputFileType = AVFileTypeQuickTimeMovie
        export.outputURL = outputURL
        export.videoComposition = composition
        
        export.exportAsynchronously {
            
            let timeTaken = now.timeIntervalSinceNow
            print("Time taken: \(timeTaken)")
            
            switch export.status {
                
            case .completed:
                print("Complete")
                
            case .cancelled:
                print("Cancelled")
                
            case .exporting:
                print("Exporting")
                
            case .failed:
                print("Failed: \(export.error!))")
                
            case .waiting:
                print("Waiting")
                
            case .unknown:
                print("Unknown")
                
            }
            
        }
        
        self.export = export
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { thisTimer in
            
            print("Progress: \(export.progress)")
            if export.progress >= 1.0 {
                thisTimer.invalidate()
            }
        }
    }
    
}

