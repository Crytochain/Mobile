//
//  TxPool.swift
//  chain3swift-iOS
//
//  Created by Dmitry on 28/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

/**
 Native realisation of txpool
 - important: Doesn't works with Gateway provider
 */
public class TxPool {
    /**
     - important: Doesn't works with Gateway provider
     */
    public static var `default`: TxPool {
        return TxPool(chain3: .default)
    }
    var chain3: Chain3
    /**
     - important: Doesn't works with Gateway provider
     */
    public init(chain3: Chain3) {
        self.chain3 = chain3
    }
    
    /**
     - important: Doesn't works with Gateway provider | main thread friendly
     - returns: number of pending and queued transactions
     - throws:
     DictionaryReader.Error if server has different response than expected |
     Chain3Error.nodeError for node error |
     Any URLSession.dataTask Error
     */
    public func status() -> Promise<TxPoolStatus> {
        let request = JsonRpcRequestFabric.prepareRequest(.txPoolStatus, parameters: [])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue ) { try TxPoolStatus($0.response()) }
    }
    
    /**
     - important: Doesn't works with Gateway provider | main thread friendly
     - returns: main information about pending and queued transactions
     - throws:
     DictionaryReader.Error if server has different response than expected |
     Chain3Error.nodeError for node error |
     Any URLSession.dataTask Error
     */
    public func inspect() -> Promise<TxPoolInspect> {
        let request = JsonRpcRequestFabric.prepareRequest(.txPoolInspect, parameters: [])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue ) { try TxPoolInspect($0.response()) }
    }
    
    /**
     - important: Doesn't works with Gateway provider | main thread friendly
     - returns: full information for all pending and queued transactions
     - throws:
     DictionaryReader.Error if server has different response than expected |
     Chain3Error.nodeError for node error |
     Any URLSession.dataTask Error
     */
    public func content() -> Promise<TxPoolContent> {
        let request = JsonRpcRequestFabric.prepareRequest(.txPoolContent, parameters: [])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue ) { try TxPoolContent($0.response()) }
    }
}

extension DictionaryReader {
    func split(_ separator: String, _ expectedSize: Int) throws -> [DictionaryReader] {
        let string = try self.string()
        let array = string.components(separatedBy: separator)
        guard array.count >= expectedSize else { throw Error.unconvertable }
        return array.map { DictionaryReader($0) }
    }
}

public struct TxPoolStatus {
    public var pending: Int
    public var queued: Int
    init(_ dictionary: DictionaryReader) throws {
        pending = try dictionary.at("pending").int()
        queued = try dictionary.at("queued").int()
    }
}

public struct TxPoolInspect {
    public let pending: [InspectedTransaction]
    public let queued: [InspectedTransaction]
    init(_ dictionary: DictionaryReader) throws {
        pending = try TxPoolInspect.parse(dictionary.at("pending"))
        queued = try TxPoolInspect.parse(dictionary.at("queued"))
    }
    init() {
        pending = []
        queued = []
    }
    private static func parse(_ reader: DictionaryReader) throws -> [InspectedTransaction] {
        var array = [InspectedTransaction]()
        try reader.dictionary {
            let from = try $0.address()
            try $1.dictionary {
                let nonce = try $0.int()
                let transaction = try InspectedTransaction($1, from: from, nonce: nonce)
                array.append(transaction)
            }
        }
        return array
    }
}

public struct InspectedTransaction {
    public let from: Address
    public let nonce: Int
    public let to: Address
    public let value: BigUInt
    public let gasLimit: BigUInt
    public let gasPrice: BigUInt
    init(_ reader: DictionaryReader, from: Address, nonce: Int) throws {
        self.from = from
        self.nonce = nonce
        let string = try reader.split(" ", 7)
        to = try string[0].address()
        value = try string[1].uint256()
        gasLimit = try string[4].uint256()
        gasPrice = try string[7].uint256()
    }
}

public struct TxPoolContent {
    public let pending: [TxPoolTransaction]
    public let queued: [TxPoolTransaction]
    init(_ dictionary: DictionaryReader) throws {
        pending = try TxPoolContent.parse(dictionary.at("pending"))
        queued = try TxPoolContent.parse(dictionary.at("queued"))
    }
    init() {
        pending = []
        queued = []
    }
    private static func parse(_ reader: DictionaryReader) throws -> [TxPoolTransaction] {
        var array = [TxPoolTransaction]()
        try reader.dictionary {
            let from = try $0.address()
            try $1.dictionary {
                let nonce = try $0.int()
                let transaction = try TxPoolTransaction($1, from: from, nonce: nonce)
                array.append(transaction)
            }
        }
        return array
    }
}

public struct TxPoolTransaction {
    public let from: Address
    public let nonce: Int
    public let to: Address
    public let value: BigUInt
    public let gasLimit: BigUInt
    public let gasPrice: BigUInt
    public let input: Data
    public let hash: Data
    public let v: BigUInt
    public let r: BigUInt
    public let s: BigUInt
    public let blockHash: Data
    public let transactionIndex: BigUInt
    init(_ reader: DictionaryReader, from: Address, nonce: Int) throws {
        self.from = from
        self.nonce = nonce
        input = try reader.at("input").data()
        gasPrice = try reader.at("gasPrice").uint256()
        s = try reader.at("s").uint256()
        to = try reader.at("to").address()
        value = try reader.at("value").uint256()
        gasLimit = try reader.at("gas").uint256()
        hash = try reader.at("hash").data()
        v = try reader.at("v").uint256()
        transactionIndex = try reader.at("transactionIndex").uint256()
        r = try reader.at("r").uint256()
        blockHash = try reader.at("blockHash").data()
    }
}

