//
//  CLTOutputFileOptions.swift
//  wateco
//
//  Created by Eisuke KASAHARA on 2023/06/16.
//

import Foundation
import ArgumentParser

struct OutputFile: ParsableArguments {
    @Option(name: [.customShort("o"), .customLong("output")],
            parsing: .next,
            help: ArgumentHelp("Write output to <file>", valueName: "file"),
            completion: .file(),
            transform: URL.init(fileURLWithPath: ))
    var url: URL? = nil
    
    mutating func validate() throws {
        let fileManager = FileManager.default
        guard let outputFile = url else {
            let currentDirectoryPath = fileManager.currentDirectoryPath
            guard fileManager.isWritableFile(atPath: currentDirectoryPath) else {
                throw ValidationError("Cannot write files to the directory '\(currentDirectoryPath)'. Please check permissions.")
            }
            return
        }
        let writeDirectory = outputFile.deletingLastPathComponent()
        guard fileManager.isWritableFile(atPath: writeDirectory.path) else {
            throw ValidationError("'Cannot write to \(outputFile.path)'. Please check permissions.")
        }
    }
}
