//
//  PCMFormat.swift
//  wateco
//
//  Created by Eisuke KASAHARA on 2023/06/19.
//

import Foundation
import AVFoundation
import ArgumentParser

enum PCMFormat: String {
    case float32
    // pcmBuffe未対応のため
//    case float64
    case int16
    case int32
    
    var audioCommonFormat: AVAudioCommonFormat {
        switch self {
        case .float32:
            return .pcmFormatFloat32
        // pcmBuffe未対応のため
//        case .float64:
//            return .pcmFormatFloat64
        case .int16:
            return .pcmFormatInt16
        case .int32:
            return .pcmFormatInt32
        }
    }
}

extension PCMFormat: CaseIterable, ExpressibleByArgument {
}
