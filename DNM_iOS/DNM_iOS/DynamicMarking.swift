//
//  DynamicMarking.swift
//  denm_view
//
//  Created by James Bean on 8/19/15.
//  Copyright © 2015 James Bean. All rights reserved.
//

import QuartzCore

public class DynamicMarking: ViewNode, BuildPattern {
    
    public var characters: [DMCharacter] = []
    public var intValues: [Int] { get { return getIntValuesWithString() } }
    public var initialIntValue: Int? { get { return intValues.first } }
    public var finalIntValue: Int? { get { return intValues.last } }
    
    public var x: CGFloat = 0
    
    public var height: CGFloat = 0
    
    public var hasBeenBuilt: Bool = false
    
    public init(string: String) {
        super.init()
        addCharactersWithString(string)
    }
    
    public init(string: String, x: CGFloat, top: CGFloat, height: CGFloat) {
        self.x = x
        self.height = height
        super.init()
        self.top = top
        addCharactersWithString(string)
        build()
    }
    
    public override init() { super.init() }
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    public override init(layer: AnyObject) { super.init(layer: layer) }
    
    public func build() {
        setFrame()
        hasBeenBuilt = true
    }
    
    private func addCharactersWithString(string: String) {
        var types: [DMCharacterType] = []
        for c in string.characters {
            let characterType = getCharacterTypeFromString(String(c))
            if characterType != nil { types.append(characterType!) }
        }
        
        var accumLeft: CGFloat = 0
        for type in types {
            let character = DMCharacter.withDMCharacterType(type, height: height)
            
            // separate out position characters, introduce kerning table: JSON
            if character != nil {
                character!.build()
                character!.position.x = accumLeft + 0.5 * character!.frame.width
                addCharacter(character!)
                if character is DMCharacter_f {
                    accumLeft += 0.618 * character!.frame.width
                }
                else if character is DMCharacter_p {
                    accumLeft += 0.85 * character!.frame.width
                }
                else if character is DMCharacter_m {
                    accumLeft += character!.frame.width
                }
                else if character is DMCharacter_o {
                    accumLeft += character!.frame.width
                }
                
                //accumLeft += character!.frame.width
            }
        }
    }
    
    private func getCharacterTypeFromString(string: String) -> DMCharacterType? {
        switch string {
        case "f": return .F
        case "p": return .P
        case "m": return .M
        case "o": return .O
        case "!": return .Exclamation
        case "(": return .Paren_open
        case ")": return .Paren_close
        default: return nil
        }
    }
    
    public func addCharacter(character: DMCharacter) {
        characters.append(character)
        addSublayer(character)
    }
    
    private func getIntValuesWithString() -> [Int] {
        var values: [Int] = []
        var fCount: Int = 0
        var pCount: Int = 0
        func pDump() { if pCount > 0 { values.append(-(pCount + 1)); pCount = 0 } }
        func fDump() { if fCount > 0 { values.append(+(fCount + 1)); fCount = 0 } }
        func bothDump() {
            if pCount > 0 { values.append(-(pCount + 1)); pCount = 0 }
            if fCount > 0 { values.append(+(fCount + 1)); fCount = 0 }
        }
        
        var c = 0
        while c < characters.count {
            let character = characters[c]
            if character is DMCharacter_m {
                if c < characters.count - 1 {
                    if characters[c + 1] is DMCharacter_p {
                        values.append(-1)
                        c += 2
                    }
                    else if characters[c + 1] is DMCharacter_f {
                        values.append(1)
                        c += 2
                    }
                }
            }
            
            else if character is DMCharacter_o {
                bothDump()
                values.append(Int.min)
                c++
            }
            else if character is DMCharacter_p {
                fDump()
                pCount++
                c++
            }
            else if character is DMCharacter_f {
                pDump()
                fCount++
                c++
            }
            else {
                c++
            }
        }
        bothDump()
        return values
    }
    
    private func setFrame() {
        let width = characters.count > 0 ? characters.last!.frame.maxX : 0
        frame = CGRectMake(x - 0.5 * width, top, width, height)
    }
}

/*
public func getIntValuesFromDynamicMarkingString(string: String) -> (Int, Int) {
    let dynamicMarking = DynamicMarking(string: string)
    
    // pray for the best
    return (dynamicMarking.intValues.first!, dynamicMarking.intValues.last!)
}
*/