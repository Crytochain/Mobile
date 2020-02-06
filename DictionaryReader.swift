//
//  DictionaryReader.swift
//  chain3swift-iOS
//
//  Created by Dmitry on 28/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    private typealias Error = DictionaryReader.Error
    init(dictionary value: Any) throws {
        if let value = value as? String {
            if value.isHex {
                guard let value = BigUInt(value.withoutHex, radix: 16) else { throw Error.unconvertable }
                self = value
            } else {
                guard let value = BigUInt(value) else { throw Error.unconvertable }
                self = value
            }
        } else if let value = value as? Int {
            self = BigUInt(value)
        } else {
            throw Error.unconvertable
        }
    }
}

public class DictionaryReader {
    public enum Error: Swift.Error {
        case notFound
        case unconvertable
    }
    public var raw: Any
    public init(_ data: Any) {
        self.raw = data
    }
    public func at(_ key: String) throws -> DictionaryReader {
        guard let data = raw as? [String: Any] else { throw Error.unconvertable }
        guard let value = data[key] else { throw Error.notFound }
        return DictionaryReader(value)
    }
    public func dictionary(block: (DictionaryReader, DictionaryReader)throws->()) throws {
        guard let data = raw as? [String: Any] else { throw Error.unconvertable }
        try data.forEach {
            try block(DictionaryReader($0),DictionaryReader($1))
        }
    }
    public func array(block: (DictionaryReader)throws->()) throws {
        guard let data = raw as? [Any] else { throw Error.unconvertable }
        try data.forEach {
            try block(DictionaryReader($0))
        }
    }

    
    public func address() throws -> Address {
        let string = try self.string()
        guard string.count >= 42 else { throw Error.unconvertable }
        guard string != "0x" && string != "0x0" else { return .contractDeployment }
        let address = Address(String(string[..<42]))
        // already checked for size. so don't need to check again for address.isValid
        // guard address.isValid else { throw Error.unconvertable }
        return address
    }
    public func string() throws -> String {
        if let value = raw as? String {
            return value
        } else if let value = raw as? Int {
            return value.description
        } else {
            throw Error.unconvertable
        }
    }
    public func data() throws -> Data {
        return try Data(hex: string().withoutHex)
    }
    public func uint256() throws -> BigUInt {
        if let value = raw as? String {
            if value.isHex {
                guard let value = BigUInt(value.withoutHex, radix: 16) else { throw Error.unconvertable }
                return value
            } else {
                guard let value = BigUInt(value) else { throw Error.unconvertable }
                return value
            }
        } else if let value = raw as? Int {
            return BigUInt(value)
        } else {
            throw Error.unconvertable
        }
    }
    public func int() throws -> Int {
        if let value = raw as? Int {
            return value
        } else if let value = raw as? String {
            if value.isHex {
                guard let value = Int(value.withoutHex, radix: 16) else { throw Error.unconvertable }
                return value
            } else {
                guard let value = Int(value) else { throw Error.unconvertable }
                return value
            }
        } else {
            throw Error.unconvertable
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    var notFoundError: Error {
        return DictionaryReader.Error.notFound
    }
    var json: Data {
        return try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    var jsonDescription: String {
        return json.string
    }
    
    public func at(_ key: String) throws -> DictionaryReader {
        guard let value = self[key] else { throw DictionaryReader.Error.notFound }
        return DictionaryReader(value)
    }
}

