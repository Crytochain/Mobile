//
//  String+Extension.swift
//  chain3swift-iOS
//
//  Created by Alexander Vlasov.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

extension String {
    subscript(range: PartialRangeUpTo<Int>) -> Substring {
        return self[..<index(range.upperBound)]
    }
    @inline(__always)
    func index(_ i: Int) -> String.Index {
        return index(startIndex, offsetBy: i)
    }
}

extension String {
    public func keccak256() -> Data {
        return data.keccak256()
    }
    var data: Data {
        return Data(utf8)
    }
    
    var fullRange: Range<Index> {
        return startIndex ..< endIndex
    }

    var fullNSRange: NSRange {
        return NSRange(fullRange, in: self)
    }

    func index(of char: Character) -> Index? {
        guard let range = range(of: String(char)) else {
            return nil
        }
        return range.lowerBound
    }

    func split(intoChunksOf chunkSize: Int) -> [String] {
        var output = [String]()
        let splittedString = map { $0 }
            .split(intoChunksOf: chunkSize)
        splittedString.forEach {
            output.append($0.map { String($0) }.joined(separator: ""))
        }
        return output
    }

    subscript(bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start ... end])
    }

    subscript(bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start ..< end])
    }

    subscript(bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = endIndex
        return String(self[start ..< end])
    }

    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(suffix(toLength))
        }
    }

    func interpretAsBinaryData() -> Data {
        let padded = padding(toLength: ((count + 7) / 8) * 8, withPad: "0", startingAt: 0)
        let byteArray = padded.split(intoChunksOf: 8).map { UInt8(strtoul($0, nil, 2)) }
        return Data(byteArray)
    }

    var isHex: Bool {
        return hasPrefix("0x")
    }

    var withHex: String {
        guard !isHex else { return self }
        return "0x" + self
    }

    var withoutHex: String {
        guard isHex else { return self }
        return String(self[2...])
    }
    var hex: Data {
        return Data(hex: withoutHex)
    }

    func dataFromHex() throws -> Data {
        let data = Data(hex: self)
        guard data.count > 0 else { throw DataError.hexStringCorrupted(self) }
        return data
    }

    func stripLeadingZeroes() -> String {
        let hex = withHex
        var count = 0
        for character in hex[2...] {
            guard character == "0" else { break }
            count += 1
        }
        guard count > 0 else { return hex }
        if count + 2 == hex.count {
            return "0x0"
        } else {
            return "0x" + hex[Int(2 + count)...]
        }
    }

    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0 ..< result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
        else { return nil }
        return from ..< to
    }

    var asciiValue: Int {
        let s = unicodeScalars
        return Int(s[s.startIndex].value)
    }
}

extension Character {
    var asciiValue: Int {
        let s = String(self).unicodeScalars
        return Int(s[s.startIndex].value)
    }
}
