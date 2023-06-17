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
}
