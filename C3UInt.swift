//
//  C3UInt.swift
//  chain3swift
//
//  Created by Dmitry on 11/8/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt

//typealias BigUInt = chain3swift.BigUInt

extension NSNumber {
	@objc public var bn: C3UInt {
		return C3UInt(value: self)
	}
}
extension BigUInt {
    public var objc: C3UInt {
		return C3UInt(value: self)
	}
}

@objc public class C3UInt: NSObject, SwiftBridgeable {
	public var swift: BigUInt {
		return value
	}
	let value: BigUInt
	init(value: BigUInt) {
		self.value = value
	}
	@objc public init(value: NSNumber) {
		self.value = BigUInt(value.uint64Value)
	}
	@objc public init(string: String, andRadix: NSNumber = 10) {
		self.value = BigUInt(string, radix: andRadix.intValue) ?? 0
	}
	
	@objc public func add(_ number: C3UInt) -> C3UInt {
		return (value + number.value).objc
	}
	@objc public func subtract(_ number: C3UInt) -> C3UInt {
		return (value - number.value).objc
	}
	@objc public func multiply(_ number: C3UInt) -> C3UInt {
		return (value * number.value).objc
	}
	@objc public func divide(_ number: C3UInt) -> C3UInt {
		return (value / number.value).objc
	}
	@objc public func remainder(_ number: C3UInt) -> C3UInt {
		return (value % number.value).objc
	}
	
	@objc public func pow(_ number: C3UInt) -> C3UInt {
		return value.power(Int(number.value)).objc
	}
	@objc public func pow(_ exponent: C3UInt, mod: C3UInt) -> C3UInt {
		return value.power(exponent.value, modulus: mod.value).objc
	}
//	@objc public func abs() -> C3UInt {
//
//	}
//	@objc public func negate() -> C3UInt {
//
//	}
	
	@objc public func bitwiseXor(_ number: C3UInt) -> C3UInt {
		return (value ^ number.value).objc
	}
	@objc public func bitwiseOr(_ number: C3UInt) -> C3UInt {
		return (value | number.value).objc
	}
	@objc public func bitwiseAnd(_ number: C3UInt) -> C3UInt {
		return (value & number.value).objc
	}
	@objc public func shiftLeft(_ number: C3UInt) -> C3UInt {
		return (value << number.value).objc
	}
	@objc public func shiftRight(_ number: C3UInt) -> C3UInt {
		return (value >> number.value).objc
	}
	
	@objc public func compare(_ number: C3UInt) -> ComparisonResult {
		if value < number.value {
			return .orderedAscending
		} else if value == number.value {
			return .orderedSame
		} else {
			return .orderedDescending
		}
	}
	
	@objc public var stringValue: String {
		return value.description
	}
	
	@objc public func stringValue(radix: Int) -> String {
		return String(value, radix: radix)
	}
	
	
	@objc public init?(_ string: String, units: C3Units) {
		guard let value = BigUInt(string, units: units.swift) else { return nil }
		self.value = value
	}
	
	public init?(_ string: String, decimals: Int) {
		guard let value = BigUInt(string, decimals: decimals) else { return nil }
		self.value = value
	}
	
	
	/// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
	/// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
	/// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
	@objc public func string(units: C3Units, decimals: Int = 18, decimalSeparator: String = ".", options: C3StringOptions = .default) -> String {
		return value.string(units: units.swift, decimals: decimals, decimalSeparator: decimalSeparator, options: options.swift)
	}
	
	/// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
	/// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
	/// Fallbacks to scientific format if higher precision is required.
	/// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
	@objc public func string(unitDecimals: Int, decimals: Int = 18, decimalSeparator: String = ".", options: C3StringOptions = .default) -> String {
		return value.string(unitDecimals: unitDecimals, decimals: decimals, decimalSeparator: decimalSeparator, options: options.swift)
	}
}

extension BigInt {
    public var objc: C3Int {
		return C3Int(value: self)
	}
}
@objc public class C3Int: NSObject {
	let value: BigInt
	init(value: BigInt) {
		self.value = value
	}
	@objc public init(value: NSNumber) {
		self.value = BigInt(value.uint64Value)
	}
	@objc public init(string: String, andRadix: NSNumber = 10) {
		self.value = BigInt(string, radix: andRadix.intValue) ?? 0
	}
	
	@objc public func add(_ number: C3Int) -> C3Int {
		return (value + number.value).objc
	}
	@objc public func subtract(_ number: C3Int) -> C3Int {
		return (value - number.value).objc
	}
	@objc public func multiply(_ number: C3Int) -> C3Int {
		return (value * number.value).objc
	}
	@objc public func divide(_ number: C3Int) -> C3Int {
		return (value / number.value).objc
	}
	@objc public func remainder(_ number: C3Int) -> C3Int {
		return (value % number.value).objc
	}
	
	@objc public func pow(_ number: C3Int) -> C3Int {
		return value.power(Int(number.value)).objc
	}
	@objc public func pow(_ exponent: C3Int, mod: C3Int) -> C3Int {
		return value.power(exponent.value, modulus: mod.value).objc
	}
	@objc public func abs() -> C3Int {
		return Swift.abs(value).objc
	}
	@objc public func negate() -> C3Int {
		var value = self.value
		value.negate()
		return value.objc
	}
	
	@objc public func bitwiseXor(_ number: C3Int) -> C3Int {
		return (value ^ number.value).objc
	}
	@objc public func bitwiseOr(_ number: C3Int) -> C3Int {
		return (value | number.value).objc
	}
	@objc public func bitwiseAnd(_ number: C3Int) -> C3Int {
		return (value & number.value).objc
	}
	@objc public func shiftLeft(_ number: C3Int) -> C3Int {
		return (value << number.value).objc
	}
	@objc public func shiftRight(_ number: C3Int) -> C3Int {
		return (value >> number.value).objc
	}
	
	@objc public func compare(_ number: C3Int) -> ComparisonResult {
		if value < number.value {
			return .orderedAscending
		} else if value == number.value {
			return .orderedSame
		} else {
			return .orderedDescending
		}
	}
	
	@objc public var stringValue: String {
		return value.description
	}
	
	@objc public func stringValue(radix: Int) -> String {
		return String(value, radix: radix)
	}
	
	@objc public func string(unitDecimals: Int, decimals: Int = 18, decimalSeparator: String = ".", options: C3StringOptions = .default) -> String {
		return value.string(unitDecimals: unitDecimals, decimals: decimals, decimalSeparator: decimalSeparator, options: options.swift)
	}
	
	/// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "units",
	/// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
	/// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
	@objc public func string(units: C3Units, decimals: Int = 18, decimalSeparator: String = ".", options: C3StringOptions = .default) -> String {
		return value.string(units: units.swift, decimals: decimals, decimalSeparator: decimalSeparator, options: options.swift)
	}
}

extension Chain3Units {
    public var objc: C3Units {
		return C3Units(rawValue: rawValue)!
	}
}
@objc public enum C3Units: Int, SwiftBridgeable {
    case mc = 18
    case sha = 0
    case Ksha = 3
    case Msha = 6
    case Gsha = 9
    case Micro = 12
    case Milli = 15
    public var swift: Chain3Units {
        return Chain3Units(rawValue: rawValue)!
    }
}

@objc public class C3StringOptions: NSObject, OptionSet {
	@objc public let rawValue: Int
	@objc public required init(rawValue: Int) {
		self.rawValue = rawValue
	}
	@objc public static let fallbackToScientific = C3StringOptions(rawValue: 0b1)
	@objc public static let stripZeroes = C3StringOptions(rawValue: 0b10)
	@objc public static let `default`: C3StringOptions = [.stripZeroes]
	public var swift: BigUInt.StringOptions {
		return BigUInt.StringOptions(rawValue: rawValue)
	}
}


@objc public class C3NaturalUnits: NSObject {
	public var swift: NaturalUnits
	@objc public init(string: String) throws {
		swift = try NaturalUnits(string)
	}
	@objc public init(_ int: Int) {
		swift = NaturalUnits(int)
	}
	public func number(with decimals: Int) -> C3UInt {
		return swift.number(with: decimals).objc
	}
}
