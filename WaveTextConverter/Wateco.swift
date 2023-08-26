//
//  Wateco.swift
//  WaveTextConverter
//
//  Created by Eisuke KASAHARA on 2023/06/12.
//

import Foundation
import ArgumentParser
import AVFAudio

@main
struct Wateco: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wateco",
        abstract: "Conversion tool for audio and text data",
        discussion: """
            This application can convert from audio file to text format or from text file to audio format.
            """,
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [ToText.self, ToWave.self],
        helpNames: [.long, .short])
    
}

extension Wateco {
    struct ToText: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Convert audio file to text format")
        
        @Option(name: .customLong("write-type"),
                parsing: .next,
                help: ArgumentHelp("Write output to <type>", valueName: "type"))
        var writeTextType: TextType = .txt
        
        @Option(parsing: .next,
                help: ArgumentHelp("Write output to <pcm-format>", valueName: "pcm-format"))
        var pcmFormat: PCMFormat = .int16
        
        @OptionGroup var outputFile: OutputFile
        @OptionGroup var inputFile: InputFile
        
        mutating func validate() throws {
            let inputFileExtention = inputFile.url.pathExtension
            let supportedExtensions = AVFormat.allCases.map({ $0.rawValue })
            guard supportedExtensions.contains(inputFileExtention) else {
                throw ValidationError("Unsupported file extension '.\(inputFileExtention)'. Please use one of the following extensions: '\(supportedExtensions.map({"." + $0}).joined(separator: ", "))'.")
            }
            
            if outputFile.url == nil {
                let fileManager = FileManager.default
                let inputFileName: String = inputFile.url.deletingPathExtension().lastPathComponent
                outputFile.url = URL(fileURLWithPath: inputFileName).appendingPathExtension(writeTextType.rawValue)
                
                guard let url = outputFile.url else {
                    throw ValidationError("Failed to create the output file path.")
                }
                let writeDirectory = url.deletingLastPathComponent()
                guard fileManager.isWritableFile(atPath: writeDirectory.path) else {
                    throw ValidationError("'Cannot write to \(url.path)'. Please check permissions.")
                }
            }
        }
        
        mutating func run() throws {
            let audioFile = try AVAudioFile(forReading: inputFile.url, commonFormat: pcmFormat.audioCommonFormat, interleaved: false)
            let audioFormat = audioFile.processingFormat
            let audioChannelCount: Int = Int(audioFormat.channelCount)
            let audioLength: Int = Int(audioFile.length)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(audioLength)) else {
                fatalError("Failed to create AVAudioPCMBuffer.")
            }
            
            try audioFile.read(into: buffer)
            
            var lines = Array<String>()
            for i in 0..<audioLength {
                var line = Array<String>()
                for j in 0..<audioChannelCount {
                    switch pcmFormat {
                    case .float32:
                        line.append(String(buffer.floatChannelData![j][i]))
                    case .int16:
                        line.append(String(buffer.int16ChannelData![j][i]))
                    case .int32:
                        line.append(String(buffer.int32ChannelData![j][i]))
                    }
                }
                lines.append(line.joined(separator: writeTextType.valueSeparator))
            }
            
            guard let data = lines.joined(separator: writeTextType.lineSeparator).data(using: .utf8) else {
                fatalError("Failed to convert data.")
            }
            guard let url = outputFile.url else {
                fatalError("Output file not specified.")
            }
            try data.write(to: url)
        }
    }
}

extension Wateco {
    struct ToWave: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Convert text file to audio format")
        
        @Option(name: .customLong("format"),
                parsing: .next,
                help: ArgumentHelp("Write output to <audio-format>", valueName: "audio-format"))
        var writeAudioFormat: AVFormat = .wav
        
        @Option(parsing: .next,
                help: ArgumentHelp("Write output to <pcm-format>", valueName: "pcm-format"))
        var pcmFormat: PCMFormat = .int16
        
        @Option(parsing: .next)
        var samplingRate: Double = 44100
        
        @Option(name: .customLong("channel"), parsing: .next)
        var channelCount: Int = 1
        
        @OptionGroup var outputFile: OutputFile
        @OptionGroup var inputFile: InputFile
        
        mutating func validate() throws {
            let inputFileExtention = inputFile.url.pathExtension
            let supportedExtensions = TextType.allCases.map({ $0.rawValue })
            guard supportedExtensions.contains(inputFileExtention) else {
                throw ValidationError("Unsupported file extension '.\(inputFileExtention)'. Please use one of the following extensions: '\(supportedExtensions.map({"." + $0}).joined(separator: ", "))'.")
            }
            
            if outputFile.url == nil {
                let fileManager = FileManager.default
                let inputFileName: String = inputFile.url.deletingPathExtension().lastPathComponent
                outputFile.url = URL(fileURLWithPath: inputFileName).appendingPathExtension(writeAudioFormat.rawValue)
                
                guard let url = outputFile.url else {
                    throw ValidationError("Failed to create the output file path.")
                }
                let writeDirectory = url.deletingLastPathComponent()
                guard fileManager.isWritableFile(atPath: writeDirectory.path) else {
                    throw ValidationError("'Cannot write to \(url.path)'. Please check permissions.")
                }
            }
        }
        func bufferWriter<T: LosslessStringConvertible>(stringValueData: [String], bufferChannelData: UnsafePointer<UnsafeMutablePointer<T>>) {
            let valueData: [T] = stringValueData.map { text in
                guard let value = T(text) else {
                    fatalError("Contains values that cannot be converted to type \(T.self).")
                }
                return value
            }
            for (i, value) in valueData.enumerated() {
                let (sample, channel) = i.quotientAndRemainder(dividingBy: channelCount)
                bufferChannelData[channel][sample] = value
            }
        }
        
        mutating func run() throws {
            let textData = try String(contentsOf: inputFile.url)
            var valueData = textData.components(separatedBy: CharacterSet(charactersIn: "\n,"))
            valueData.removeAll(where: { $0.isEmpty })
            let valueDataLength = valueData.count / channelCount
            
            guard let audioFormat = AVAudioFormat(commonFormat: pcmFormat.audioCommonFormat, sampleRate: samplingRate, channels: AVAudioChannelCount(channelCount), interleaved: false) else {
                fatalError("Failed to create AudioFormat.")
            }
            guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(valueDataLength)) else {
                fatalError("Failed to create AVAudioPCMBuffer.")
            }
            pcmBuffer.frameLength = AVAudioFrameCount(valueDataLength)
            
            switch pcmFormat {
            case .float32:
                guard let floatChannelData = pcmBuffer.floatChannelData else {
                    fatalError("Failed to create AVAudioPCMBuffer floatChannelData.")
                }
                bufferWriter(stringValueData: valueData, bufferChannelData: floatChannelData)
            case .int16:
                guard let int16ChannelData = pcmBuffer.int16ChannelData else {
                    fatalError("Failed to create AVAudioPCMBuffer int16ChannelData.")
                }
                bufferWriter(stringValueData: valueData, bufferChannelData: int16ChannelData)
            case .int32:
                guard let int32ChannelData = pcmBuffer.int32ChannelData else {
                    fatalError("Failed to create AVAudioPCMBuffer int32ChannelData.")
                }
                bufferWriter(stringValueData: valueData, bufferChannelData: int32ChannelData)
            }
            
            do {
                let audioSettings: [String: Any] = [
                    "AVFormatIDKey": writeAudioFormat.audioFormatID,
                    "AVSampleRateKey": samplingRate,
                    "AVNumberOfChannelsKey": channelCount
                ]
                guard let writingURL = outputFile.url else {
                    throw ValidationError("Failed to create the output file path.")
                }
                let audioFile = try AVAudioFile(forWriting: writingURL, settings: audioSettings, commonFormat: audioFormat.commonFormat , interleaved: true)
                
                try audioFile.write(from: pcmBuffer)
            }
            
        }
        
    }
}

