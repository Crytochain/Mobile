//
//  Chain3+Protocols.swift
//  chain3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation
import class PromiseKit.Promise

/// Protocol for generic LBR event parsing results
public protocol EventParserResultProtocol {
    var eventName: String { get }
    var decodedResult: [String: Any] { get }
    var contractAddress: Address { get }
    var transactionReceipt: TransactionReceipt? { get }
    var eventLog: EventLog? { get }
}

/// Protocol for generic LBR event parser
public protocol EventParserProtocol {
    func parseTransaction(_ transaction: LBRTransaction) throws -> [EventParserResultProtocol]
    func parseTransactionByHash(_ hash: Data) throws -> [EventParserResultProtocol]
    func parseBlock(_ block: Block) throws -> [EventParserResultProtocol]
    func parseBlockByNumber(_ blockNumber: UInt64) throws -> [EventParserResultProtocol]
    func parseTransactionPromise(_ transaction: LBRTransaction) -> Promise<[EventParserResultProtocol]>
    func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]>
    func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]>
    func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]>
}

/// Enum for the most-used LBR networks. Network ID is crucial for EIP155 support
public struct NetworkId: RawRepresentable, CustomStringConvertible, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public var rawValue: BigUInt
    public init(rawValue: BigUInt) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: BigUInt) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Int) {
        self.rawValue = BigUInt(rawValue)
    }

    public init(integerLiteral value: Int) {
        rawValue = BigUInt(value)
    }

    public var all: [NetworkId] {
        return [.mainnet, .ropsten, .rinkeby, .kovan]
    }

    public static var `default`: NetworkId = .mainnet
    public static var mainnet: NetworkId { return 1 }
    public static var ropsten: NetworkId { return 3 }
    public static var rinkeby: NetworkId { return 4 }
    public static var kovan: NetworkId { return 42 }
    public var description: String {
        switch rawValue {
        case 1: return "mainnet"
        case 3: return "ropsten"
        case 4: return "rinkeby"
        case 42: return "kovan"
        default: return ""
        }
    }
}

extension NetworkId: Numeric {
    public typealias Magnitude = RawValue.Magnitude
    public var magnitude: RawValue.Magnitude {
        return rawValue.magnitude
    }

    public init?<T>(exactly source: T) where T: BinaryInteger {
        rawValue = RawValue(source)
    }

    public static func * (lhs: NetworkId, rhs: NetworkId) -> NetworkId {
        return NetworkId(rawValue: lhs.rawValue * rhs.rawValue)
    }

    public static func *= (lhs: inout NetworkId, rhs: NetworkId) {
        lhs.rawValue *= rhs.rawValue
    }

    public static func + (lhs: NetworkId, rhs: NetworkId) -> NetworkId {
        return NetworkId(rawValue: lhs.rawValue + rhs.rawValue)
    }

    public static func += (lhs: inout NetworkId, rhs: NetworkId) {
        lhs.rawValue += rhs.rawValue
    }

    public static func - (lhs: NetworkId, rhs: NetworkId) -> NetworkId {
        return NetworkId(rawValue: lhs.rawValue - rhs.rawValue)
    }

    public static func -= (lhs: inout NetworkId, rhs: NetworkId) {
        lhs.rawValue -= rhs.rawValue
    }
}
