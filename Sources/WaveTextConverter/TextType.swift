//
//  TextType.swift
//  wateco
//
//  Created by Eisuke KASAHARA on 2023/06/17.
//

import Foundation
import ArgumentParser

enum TextType: String {
    case txt, dat, csv
}

extension TextType: CaseIterable, ExpressibleByArgument {
    var valueSeparator: String {
        switch self {
        case .txt, .dat:
            return "\n"
        case .csv:
            return ","
        }
    }
    var lineTerminator: String {
        switch self {
        case .txt, .dat, .csv:
            return "\n"
        }
    }
}
