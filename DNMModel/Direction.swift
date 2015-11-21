//
//  Direction.swift
//  denm_model
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import Foundation

public enum Direction {
    case None, North, South, East, West, NorthEast, NorthWest, SouthEast, SouthWest
}

public enum DirectionCardinal {
    case None, North, South, East, West, NorthEast, NorthWest, SouthEast, SouthWest
}

public enum DirectionRelative: Int {
    case Up, Down, Left, Right, None
}

public enum PositionRelative {
    case Above, Below, Left, Right, None
}

public enum PositionAbsolute {
    case Top, Bottom, Left, Right, Center, Middle, None
}

public enum Alignment{
    case Left
    case Center
    case Right
    case Top
    case Middle
    case Bottom
}

public enum LayoutDirectionHorizontal {
    case None, Left, Center, Right
}

public enum LayoutDirectionVertical {
    case None, Top, Middle, Bottom
}