//
//  ContractProtocol.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

public protocol ContractProtocol {
    var address: Address? { get set }
    var options: Chain3Options { get set }
    var allMethods: [String] { get }
    var allEvents: [String] { get }
    func deploy(bytecode: Data, parameters: [Any], extraData: Data, options: Chain3Options?) throws -> LBRTransaction
    func method(_ method: String, parameters: [Any], extraData: Data, options: Chain3Options?) throws -> LBRTransaction
    init(_ abiString: String, at address: Address?) throws
    func decodeReturnData(_ method: String, data: Data) -> [String: Any]?
    func decodeInputData(_ method: String, data: Data) -> [String: Any]?
    func decodeInputData(_ data: Data) -> [String: Any]?
    func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?)
    func testBloomForEventPrecence(eventName: String, bloom: LBRBloomFilter) -> Bool?
//    func allEvents() -> [String: [String: Any]?]
}

public protocol EventFilterComparable {
    func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
    func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable {}

extension BigUInt: EventFilterable {}

extension BigInt: EventFilterable {}

extension Data: EventFilterable {}

extension String: EventFilterable {}

extension Address: EventFilterable {}

public struct EventFilter {
    public enum Block {
        case latest
        case pending
        case blockNumber(UInt64)

        var encoded: String {
            switch self {
            case .latest:
                return "latest"
            case .pending:
                return "pending"
            case let .blockNumber(number):
                return String(number, radix: 16).withHex
            }
        }
    }

    public init() {}

    public init(fromBlock: Block?, toBlock: Block?,
                addresses: [Address]? = nil,
                parameterFilters: [[EventFilterable]?]? = nil) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.addresses = addresses
        self.parameterFilters = parameterFilters
    }

    public var fromBlock: Block?
    public var toBlock: Block?
    public var addresses: [Address]?
    public var parameterFilters: [[EventFilterable]?]?

    public func rpcPreEncode() -> EventFilterParameters {
        var encoding = EventFilterParameters()
        if fromBlock != nil {
            encoding.fromBlock = fromBlock!.encoded
        }
        if toBlock != nil {
            encoding.toBlock = toBlock!.encoded
        }
        if addresses != nil {
            if addresses!.count == 1 {
                encoding.address = [self.addresses![0].address]
            } else {
                var encodedAddresses = [String?]()
                for addr in addresses! {
                    encodedAddresses.append(addr.address)
                }
                encoding.address = encodedAddresses
            }
        }
        return encoding
    }
}
