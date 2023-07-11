//
//  AVFormat.swift
//  wateco
//
//  Created by Eisuke KASAHARA on 2023/06/17.
//

import Foundation
import AVFoundation
import ArgumentParser

enum AVFormat: String {
    case wav
    case aiff
    case appleLossless = "alac"
    case aac
    case mp3
    
    var audioFormatID: AudioFormatID {
        switch self {
        case .wav:
            return kAudioFormatLinearPCM
        case .aiff:
            return kAudioFormatLinearPCM
        case .appleLossless:
            return kAudioFormatAppleLossless
        case .aac:
            return kAudioFormatMPEG4AAC
        case .mp3:
            return kAudioFormatMPEGLayer3
        }
    }
}

extension AVFormat: CaseIterable, ExpressibleByArgument {
}
