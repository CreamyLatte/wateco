//
//  CLTInputFileOptions.swift
//  wateco
//
//  Created by Eisuke KASAHARA on 2023/06/16.
//

import Foundation
import ArgumentParser

struct InputFile: ParsableArguments {
    @Argument(
        help: ArgumentHelp("Specifies the input file to read from", valueName: "input-file"),
        completion: .file(),
        transform: URL.init(fileURLWithPath: ))
    var url: URL
    
    mutating func validate() throws {
        let fileManager = FileManager.default
        guard fileManager.isReadableFile(atPath: url.path) else {
            throw ValidationError("'\(url.path)' does not exist or cannot be read. Please check permissions.")
        }
    }
}

