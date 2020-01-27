//
//  SolidityTypes.swift
//  chain3swift
//
//  Created by Dmitry on 16/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt

public enum AbiError: Error {
    /// Unsupported types: function, tuple
    case unsupportedType
}

/**
 Solidity types bridge
 Used to generate solidity function input from swift types
 
 Types:
 ```
 uint8, uint16, uint24, uint32 ... uint248, uint256
 int8, int16, int24, int32 ... int248, int256
 function, address, bool, string
 bytes
 bytes1, bytes2, bytes3 ... bytes31, bytes32
 
 array: type[]
 array: type[1...]
 tuple(type1,type2,type3...)
 example: tuple(uint256,address,tuple(address,bytes32,uint256[64]))
 ```
 */
public class SolidityType: Equatable, CustomStringConvertible {
    /// SolidityType array size
    public enum ArraySize {
        /// returns number of elements in a static array
        case `static`(Int)
        /// dynamic array
        case dynamic
        /// for non array types
        case notArray
    }
    /// returns true if type is static (not not uses data pointer in abi). default: true
    public var isStatic: Bool { return true }
    /// returns true if type is array. default: false
    public var isArray: Bool { return false }
    /// returns true if type is tuple. default: false
    /// - important: tuples are not supported at this moment
    public var isTuple: Bool { return false }
    /// returns number of elements in array if it static. default: .notArray
    public var arraySize: ArraySize { return .notArray }
    /// returns type's subtype used in array types. default: nil
    public var subtype: SolidityType? { return nil }
    /// returns type memory usage. default: 32
    public var memoryUsage: Int { return 32 }
    /// returns default data for empty value. default: Data(repeating: 0, count: memoryUsage)
    public var `default`: Data { return Data(count: memoryUsage) }
    /// - returns string representation of solidity type
    public var description: String { return "" }
    /// returns true if type input parameters is valid: default true
    public var isValid: Bool { return true }
    /// returns true if type is supported in chain3swift
    public var isSupported: Bool { return true }
    
    public static func == (lhs: SolidityType, rhs: SolidityType) -> Bool {
        return lhs.description == rhs.description
    }
    
    /// Type conversion error
    public enum Error: Swift.Error {
        case corrupted
    }
    public class SUInt: SolidityType {
        var bits: Int
        init(bits: Int) {
            self.bits = bits
            super.init()
        }
        public override var description: String { return "uint\(bits)" }
        public override var isValid: Bool {
            return (8...256).contains(bits) && (bits & 0b111 == 0)
        }
    }
    public class SInt: SUInt {
        public override var description: String { return "int\(bits)" }
    }
    public class SAddress: SolidityType {
        public override var description: String { return "address" }
    }
    
    /// Unsupported
    public class SFunction: SolidityType {
        public override var description: String { return "function" }
        public override var isSupported: Bool { return false }
    }
    public class SBool: SolidityType {
        public override var description: String { return "bool" }
    }
    public class SBytes: SolidityType {
        public override var description: String { return "bytes\(count)" }
        public override var isValid: Bool { return count > 0 && count <= 32 }
        var count: Int
        init(count: Int) {
            self.count = count
            super.init()
        }
    }
    public class SDynamicBytes: SolidityType {
        public override var description: String { return "bytes" }
        public override var memoryUsage: Int { return 0 }
        public override var isStatic: Bool { return false }
    }
    public class SString: SolidityType {
        public override var description: String { return "string" }
        public override var isStatic: Bool { return false }
        public override var memoryUsage: Int { return 0 }
    }
    
    public class SStaticArray: SolidityType {
        public override var description: String { return "\(type)[\(count)]" }
        public override var isStatic: Bool { return type.isStatic }
        public override var isArray: Bool { return true }
        public override var subtype: SolidityType? { return type }
        public override var arraySize: ArraySize { return .static(count) }
        public override var isValid: Bool { return type.isValid }
        public override var memoryUsage: Int {
            return 32 * count
        }
        var count: Int
        var type: SolidityType
        init(count: Int, type: SolidityType) {
            self.count = count
            self.type = type
            super.init()
        }
    }
    public class SDynamicArray: SolidityType {
        public override var description: String { return "\(type)[]" }
        public override var memoryUsage: Int { return 0 }
        public override var isStatic: Bool { return type.isStatic }
        public override var isArray: Bool { return true }
        public override var subtype: SolidityType? { return type }
        public override var arraySize: ArraySize { return .dynamic }
        public override var isValid: Bool { return type.isValid }
        var type: SolidityType
        init(type: SolidityType) {
            self.type = type
            super.init()
        }
    }
    
    /**
     Unsupported. But you can still parse it using
     ```
     let type = SolidityType.scan("tuple(uint256,uint256")
     ```
     */
    public class SolidityTuple: SolidityType {
        public override var description: String { return "tuple(\(types.map { $0.description }.joined(separator: ",")))" }
        public override var isStatic: Bool { return types.allSatisfy { $0.isStatic } }
        public override var isTuple: Bool { return true }
        public override var isSupported: Bool { return false }
        public override var memoryUsage: Int {
            guard isStatic else { return 32 }
            return types.reduce(0, { $0 + $1.memoryUsage })
        }
        public override var isValid: Bool { return types.allSatisfy { $0.isValid } }
        var types: [SolidityType]
        init(types: [SolidityType]) {
            self.types = types
            super.init()
        }
    }
}

// MARK:- String to SolidityType
extension SolidityType {
    private static var knownTypes: [String: SolidityType] = [
        "function": SFunction(),
        "address": SAddress(),
        "string": SString(),
        "bool": SBool(),
        "uint": SUInt(bits: 256),
        "int": SInt(bits: 256)
    ]
    private static func scan(tuple string: String, from index: Int) throws -> SolidityType {
        guard string.last! == ")" else { throw Error.corrupted }
        guard string[..<index] == "tuple" else { throw Error.corrupted }
        let string = string[index+1..<string.count-1]
        let array = try string.split(separator: ",").map { try scan(type: String($0)) }
        return SolidityTuple(types: array)
    }
    private static func scan(arraySize string: String, from index: Int) throws -> SolidityType {
        guard string.last! == "]" else { throw Error.corrupted }
        let prefix = string[..<index]
        guard let type = knownTypes[String(prefix)] else { throw Error.corrupted }
        // type.isValid == true
        let string = string[index+1..<string.count-1]
        if string.isEmpty {
            return SDynamicArray(type: type)
        } else {
            guard let count = Int(string) else { throw Error.corrupted }
            guard count > 0 else { throw Error.corrupted }
            return SStaticArray(count: count, type: type)
        }
    }
    private static func scan(bytesArray string: String, from index: Int) throws -> SolidityType {
        guard let count = Int(string[index...]) else { throw Error.corrupted }
        let type = SBytes(count: count)
        guard type.isValid else { throw Error.corrupted }
        return type
    }
    private static func scan(number string: String, from index: Int) throws -> SolidityType {
        let prefix = string[..<index]
        let isSigned: Bool
        switch prefix {
        case "uint":
            isSigned = false
        case "int":
            isSigned = true
        default: throw Error.corrupted
        }
        let i = index+1
        for (index2,character) in string[i...].enumerated() {
            switch character {
            case "[":
                guard let number = Int(string[index...index+index2]) else { throw Error.corrupted }
                let type = isSigned ? SInt(bits: number) : SUInt(bits: number)
                guard type.isValid else { throw Error.corrupted }
                guard string.last! == "]" else { throw Error.corrupted }
                // type.isValid == true
                let string = string[index+index2+2..<string.count-1]
                if string.isEmpty {
                    return SDynamicArray(type: type)
                } else {
                    guard let count = Int(string) else { throw Error.corrupted }
                    guard count > 0 else { throw Error.corrupted }
                    let array = SStaticArray(count: count, type: type)
                    guard array.isValid else { throw Error.corrupted }
                    return array
                }
            case "0"..."9":
                guard index2 < 3 else { throw Error.corrupted }
                continue
            default: throw Error.corrupted
            }
        }
        guard let number = Int(string[index...]) else { throw Error.corrupted }
        let type = isSigned ? SInt(bits: number) : SUInt(bits: number)
        guard type.isValid else { throw Error.corrupted }
        return type
    }
    /**
     converts single solidity type to native type:
     SolidityFunction uses this method to parse the whole function to name and input types
     example:
     ```
     let type = try! SolidityType.parse("uint256")
     print(type) // prints uint256
     print(type is SolidityType.SUInt) // prints true
     print((type as! SolidityType.SUInt).bits) // prints 256
     ```
     */
    public static func scan(type string: String) throws -> SolidityType {
        for (index,character) in string.enumerated() {
            switch character {
            case "(":
                return try scan(tuple: string, from: index)
            case "[":
                return try scan(arraySize: string, from: index)
            case "0"..."9":
                let prefix = string[..<index]
                if prefix == "bytes" {
                    return try scan(bytesArray: string, from: index)
                } else {
                    return try scan(number: string, from: index)
                }
            default: continue
            }
        }
        if string == "bytes" {
            return SDynamicBytes()
        } else if let type = knownTypes[String(string)] {
            return type
        } else {
            throw Error.corrupted
        }
    }
}


/**
 Solidity function to native type parser.
 
 • Mainthread-friendly
 
Converts:
 ```
 "balanceOf(address)"
 "transfer(address,address,uint256)"
 "transfer(address, address, uint256)"
 "transfer(address, address, uint256)"
 "transfer (address, address, uint)"
 "  transfer  (  address  ,  address  ,  uint256  )  "
 ```
To:
 ```
 function.name: String
 function.types: [SolidityType]
 ```
 
 
 Automatically converts uint to uint256.
 So return the same hash for
 ```
 "transfer(address,address,uint256)"
 ```
 and
 ```
 "transfer(address,address,uint)"
 ```

 
Performance:
 ```
  // ~184k operations per second
 var function = try! SolidityFunction("transfer(uint256,address)")
 
 // ~100k operations per second
 function = try! SolidityFunction("transfer(uint256,address,address,bytes32,uint256[32])")
 ```
 */

public class SolidityFunction: CustomStringConvertible {
    public enum Error: Swift.Error {
        case corrupted
        case emptyFunctionName
    }
    public let name: String
    public let types: [SolidityType]
    public let function: String
    public lazy var hash: Data = self.function.keccak256()[0..<4]
    public init(function: String) throws {
        let function = function.replacingOccurrences(of: " ", with: "")
        guard let index = function.index(of: "(") else { throw Error.corrupted }
        name = String(function[..<index])
        guard name.count > 0 else { throw Error.emptyFunctionName }
        guard function.hasSuffix(")") else { throw Error.corrupted }
        let arguments = function[function.index(after: index)..<function.index(before: function.endIndex)]
        self.types = try arguments.split(separator: ",").map { try SolidityType.scan(type: String($0)) }
        self.function = "\(name)(\(types.map { $0.description }.joined(separator: ",")))"
    }
    public func encode(_ arguments: SolidityDataRepresentable...) -> Data {
        return encode(arguments)
    }
    public func encode(_ arguments: [SolidityDataRepresentable]) -> Data {
        let data = SolidityDataWriter()
        data.write(header: hash)
        for i in 0..<types.count {
            let type = types[i]
            if i < arguments.count {
                data.write(value: arguments[i], type: type)
            } else {
                data.write(type: type)
            }
        }
        return data.done()
    }
    public var description: String {
        return "\(name)(\(types.map{ $0.description }.joined(separator: ",")))"
    }
}
