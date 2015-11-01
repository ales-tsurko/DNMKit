//
//  Items.swift
//  denm_parser
//
//  Created by James Bean on 8/15/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

internal enum Item/*: CustomStringConvertible*/ {
    case BOF
    case EOF
    case NewLine
    case Indent
    case Space
    case Character(value: String)
    case BlockCommentStart
    case BlockCommentStop
    case LineCommentStart
}