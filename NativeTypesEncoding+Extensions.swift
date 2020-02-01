//
//  NativeTypesEncoding+Extensions.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 03.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

public extension Data {
    func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        var data: Data
        if isNegative {
            data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
        } else {
            data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
        }
        data.append(self)
        return data
    }

    func setLengthRight(_ toBytes: UInt64, isNegative: Bool = false) -> Data? {
        let existingLength = UInt64(count)
        if existingLength == toBytes {
            return Data(self)
        } else if existingLength > toBytes {
            return nil
        }
        var data: Data = Data()
        data.append(self)
        if isNegative {
            data.append(Data(repeating: UInt8(255), count: Int(toBytes - existingLength)))
        } else {
            data.append(Data(repeating: UInt8(0), count: Int(toBytes - existingLength)))
        }
        return data
    }
}

public extension BigInt {
    func toTwosComplement() -> Data {
        if sign == BigInt.Sign.plus {
            return magnitude.serialize()
        } else {
            let serializedLength = magnitude.serialize().count
            let MAX = BigUInt(1) << (serializedLength * 8)
            let twoComplement = MAX - magnitude
            return twoComplement.serialize()
        }
    }

    func abiEncode(bits: UInt64) -> Data! {
        let isNegative = self < (BigInt(0))
        let data = toTwosComplement()
        let paddedLength = UInt64(ceil((Double(bits) / 8.0)))
        let padded = data.setLengthLeft(paddedLength, isNegative: isNegative)!
        return padded
    }

    static func fromTwosComplement(data: Data) -> BigInt {
        let isPositive = ((data[0] & 128) >> 7) == 0
        if isPositive {
            let magnitude = BigUInt(data)
            return BigInt(magnitude)
        } else {
            let MAX = (BigUInt(1) << (data.count * 8))
            let magnitude = MAX - BigUInt(data)
            let bigint = BigInt(0) - BigInt(magnitude)
            return bigint
        }
    }
}

public extension BigUInt {
    func abiEncode(bits: UInt64) -> Data? {
        let data = serialize()
        let paddedLength = UInt64(ceil((Double(bits) / 8.0)))
        let padded = data.setLengthLeft(paddedLength)
        return padded
    }
}
