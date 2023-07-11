//
//  Wateco.swift
//  WaveTextConverter
//
//  Created by Eisuke KASAHARA on 2023/06/12.
//

import Foundation
import ArgumentParser

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

        @OptionGroup var outputFile: OutputFile
        @OptionGroup var inputFile: InputFile
        
        mutating func run() {
            print(inputFile.url)
        }
    }
}

extension Wateco {
    struct ToWave: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Convert text file to audio format")
        
        @OptionGroup var outputFile: OutputFile
        @OptionGroup var inputFile: InputFile
    }
}

