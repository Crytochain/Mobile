//
//  Chain3+TransactionIntermediate.swift
//  chain3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

public enum Chain3ResponseError: Error {
    case notFound
    case wrongType
    case overflows
}

private extension Int {
    var solidityFormatted: Int {
        return (self / 32 + 1) * 32
    }
}

public class Chain3DataResponse {
    public let data: Data
    public var position = 0
    public var headerSize = 0
    public init(_ data: Data) {
        self.data = data
    }
    public func uint256() throws -> BigUInt {
        return try BigUInt(next(32))
    }
    public func address() throws -> Address {
        try skip(12)
        return try Address(next(20))
    }
    public func bool() throws -> Bool {
        let value = try BigUInt(next(32))
        guard value < 2 else { throw Chain3ResponseError.wrongType }
        return value == 1
    }
    public func string32() throws -> String {
        var data = try next(32)
        let index = data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> Int? in
            for i in 0..<data.count where pointer[i] == 0 {
                return i
            }
            return nil
        }
        if let index = index {
            data = data[0..<index]
        }
        guard let string = String(data: data, encoding: .utf8) else { throw Chain3ResponseError.wrongType }
        return string
    }
    public func string() throws -> String {
        let pointer = try view { try uint256() }
        if pointer == 0 {
            // we already checked next 32 bytes so this shouldn't crash
            try! skip(32)
            return ""
        } else if pointer < Int.max {
            return try stringPointer()
        } else {
            return try string32()
        }
    }
    public func stringPointer() throws -> String {
        return try pointer {
            let length = try intCount()
            guard length > 0 else { return "" }
            let data = try self.next(length)
            guard let string = String(data: data, encoding: .utf8) else { throw Chain3ResponseError.wrongType }
            return string
        }
    }
    public func array<T>(builder: (Chain3DataResponse)throws->(T)) throws -> [T] {
        return try pointer {
            let count = try intCount()
            var array = [T]()
            array.reserveCapacity(count)
            for _ in 0..<count {
                try array.append(builder(self))
            }
            return array
        }
    }
    
    public func header(_ size: Int) throws -> Data {
        let range = position..<position+size
        guard range.upperBound <= data.count else { throw Chain3ResponseError.notFound }
        position = range.upperBound
        headerSize = size
        return self.data[range]
    }
    public func skip(_ count: Int) throws {
        let end = position+count
        guard end <= data.count else { throw Chain3ResponseError.notFound }
        position = end
    }
    public func next(_ size: Int) throws -> Data {
        let range = position..<position+size
        guard range.upperBound <= data.count else { throw Chain3ResponseError.notFound }
        position = range.upperBound
        return self.data[range]
    }
    public func pointer<T>(at: Int, block: ()throws->T) throws -> T {
        let pos = position
        position = at + headerSize
        defer { position = pos }
        return try block()
    }
    public func pointer<T>(block: ()throws->T) throws -> T {
        let pointer = try intCount()
        let pos = position
        position = pointer + headerSize
        defer { position = pos }
        return try block()
    }
    public func view<T>(block: ()throws->T) throws -> T {
        let pos = position
        defer { position = pos }
        return try block()
    }
}
public extension Chain3DataResponse {
    private func unsigned<T: BinaryInteger>(max: BigUInt) throws -> T {
        let number = try uint256()
        guard number <= max else { throw Chain3ResponseError.overflows }
        return T(number)
    }
    private func signed<T: BinaryInteger>(min: BigInt, max: BigInt) throws -> T {
        let number = try uint256()
        guard number >= min && number <= max else { throw Chain3ResponseError.overflows }
        return T(number)
    }
    func uint8() throws -> UInt8 {
        return try unsigned(max: 0xff)
    }
    func uint16() throws -> UInt16 {
        return try unsigned(max: 0xffff)
    }
    func uint32() throws -> UInt32 {
        return try unsigned(max: 0xffffffff)
    }
    func uint64() throws -> UInt64 {
        return try unsigned(max: 0xffffffffffffffff)
    }
    func uint() throws -> Int64 {
        return try unsigned(max: BigUInt(UInt.max))
    }
    func int8() throws -> Int8 {
        return try signed(min: -0x80, max: 0x7f)
    }
    func int16() throws -> Int16 {
        return try signed(min: -0x8000, max: 0x7fff)
    }
    func int32() throws -> Int32 {
        return try signed(min: -0x80000000, max: 0x7fffffff)
    }
    func int64() throws -> Int64 {
        return try signed(min: -0x8000000000000000, max: 0x7fffffffffffffff)
    }
    func int() throws -> Int64 {
        return try signed(min: BigInt(Int.min), max: BigInt(Int.max))
    }
    func intCount() throws -> Int {
        return try signed(min: 0, max: BigInt(Int.max))
    }
}

public class Chain3Response {
    let dictionary: [String: Any]
    public var position = 0
    init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    public subscript(key: String) -> Any? {
        return dictionary[key]
    }

    public subscript(index: Int) -> Any? {
        return dictionary["\(index)"]
    }

    /// Returns next response argument as BigUInt (like self[n] as? BigUInt; n += 1)
    /// throws Chain3ResponseError.notFound if there is no value at self[n]
    /// throws Chain3ResponseError.wrongType if it cannot cast self[n] to BigUInt
    public func uint256() throws -> BigUInt {
        guard let value = dictionary[nextIndex] else { throw Chain3ResponseError.notFound }
        if let value = value as? BigUInt {
            return value
        } else if let value = value as? String {
            guard let value = BigUInt(value.withoutHex, radix: 16) else { throw Chain3ResponseError.wrongType }
            return value
        } else {
            throw Chain3ResponseError.wrongType
        }
    }

    /// Returns next response argument as Address (like self[n] as? Address; n += 1)
    /// throws Chain3ResponseError.notFound if there is no value at self[n]
    /// throws Chain3ResponseError.wrongType if it cannot cast self[n] to Address
    public func address() throws -> Address {
        guard let value = dictionary[nextIndex] else { throw Chain3ResponseError.notFound }
        guard let address = value as? Address else { throw Chain3ResponseError.wrongType }
        return address
    }

    /// Returns next response argument as String (like self[n] as? String; n += 1)
    /// throws Chain3ResponseError.notFound if there is no value at self[n]
    /// throws Chain3ResponseError.wrongType if it cannot cast self[n] to String
    public func string() throws -> String {
        guard let value = dictionary[nextIndex] else { throw Chain3ResponseError.notFound }
        guard let string = value as? String else { throw Chain3ResponseError.wrongType }
        return string
    }

    public func next() throws -> Any {
        guard let value = dictionary[nextIndex] else { throw Chain3ResponseError.notFound }
        return value
    }

    private var nextIndex: String {
        let p = position
        position += 1
        return String(p)
    }
}

extension Chain3Contract {
    public typealias TransactionIntermediate = chain3swift.TransactionIntermediate
    /// TransactionIntermediate is an almost-ready transaction or a smart-contract function call. It bears all the required information
    /// to call the smart-contract and decode the returned information, or estimate gas required for transaction, or send a transaciton
    /// to the blockchain.
}

public class TransactionIntermediate {
    public var transaction: LBRTransaction
    public var contract: ContractProtocol
    public var method: String
    public var options: Chain3Options = .default
    var chain3: Chain3
    public init(transaction: LBRTransaction, chain3 chain3Instance: Chain3, contract: ContractProtocol, method: String, options: Chain3Options) {
        self.transaction = transaction
        chain3 = chain3Instance
        self.contract = contract
        self.contract.options = options
        self.method = method
        self.options = chain3.options.merge(with: options)
        if chain3.provider.network != nil {
            self.transaction.chainID = chain3.provider.network
        }
    }
    
    /**
     *Send a prepared transaction to the blockchain. Internally checks the nonce for a sending account, assigns it, get a gas estimate and signs a transaction either locally or on the remote node.*
     
     - parameter password: Password for a private key if transaction is signed locally
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: TransactionSendingResult
     - important: This call is synchronous
     */
    @discardableResult
    public func send(password: String = "BANKEXFOUNDATION", options: Chain3Options? = nil, onBlock: String = "pending") throws -> TransactionSendingResult {
        return try sendPromise(password: password, options: options, onBlock: onBlock).wait()
    }
    
    /**
     *Calls a function of the smart-contract and parses the returned data to native objects.*
     
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: Chain3Response from node
     - important: This call is synchronous
     
     */
    
    @discardableResult
    public func call(options: Chain3Options?, onBlock: String = "latest") throws -> Chain3Response {
        return try callPromise(options: options, onBlock: onBlock).wait()
    }
    
    /**
     *Estimates gas required to execute the transaction. Setting a gas limit lower than the estimate will most likely result in a failed transaction. If this call returns an error it can also indicate that transaction is invalid as itself.*
     
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: gas price
     - important: This call is synchronous
     
     */
    public func estimateGas(options: Chain3Options?, onBlock: String = "latest") throws -> BigUInt {
        return try estimateGasPromise(options: options, onBlock: onBlock).wait()
    }
    
    /**
     *Assembles (but does not sign!) a transaction by fetching the nonce value and applying provided options.*
     
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: transaction
     - important: This call is synchronous
     
     */
    public func assemble(options: Chain3Options? = nil, onBlock: String = "pending") throws -> LBRTransaction {
        return try assemblePromise(options: options, onBlock: onBlock).wait()
    }
    
    /**
     *Assembles (but does not sign!) a transaction by fetching the nonce value and applying provided options.*
     
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: Promise for LBR transaction
     */
    public func assemblePromise(options: Chain3Options? = nil, onBlock: String = "pending") -> Promise<LBRTransaction> {
        var assembledTransaction: LBRTransaction = transaction
        let queue = chain3.requestDispatcher.queue
        let returnPromise = Promise<LBRTransaction> { seal in
            let mergedOptions = self.options.merge(with: options)
            guard let from = mergedOptions.from else {
                seal.reject(Chain3Error.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = Chain3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let getNoncePromise: Promise<BigUInt> = self.chain3.mc.getTransactionCountPromise(address: from, onBlock: onBlock)
            let gasEstimatePromise: Promise<BigUInt> = self.chain3.mc.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            let gasPricePromise: Promise<BigUInt> = self.chain3.mc.getGasPricePromise()
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise, gasPricePromise, gasPricePromise]
            when(resolved: getNoncePromise, gasEstimatePromise, gasPricePromise).map(on: queue, { (results: [Result<BigUInt>]) throws -> LBRTransaction in
                
                promisesToFulfill.removeAll()
                guard case let .fulfilled(nonce) = results[0] else {
                    throw Chain3Error.processingError("Failed to fetch nonce")
                }
                guard case let .fulfilled(gasEstimate) = results[1] else {
                    throw Chain3Error.processingError("Failed to fetch gas estimate")
                }
                guard case let .fulfilled(gasPrice) = results[2] else {
                    throw Chain3Error.processingError("Failed to fetch gas price")
                }
                let estimate = Chain3Options.smartMergeGasLimit(originalOptions: options, extraOptions: mergedOptions, gasEstimate: gasEstimate)
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                let finalGasPrice = Chain3Options.smartMergeGasPrice(originalOptions: options, extraOptions: mergedOptions, priceEstimate: gasPrice)
                assembledTransaction.gasPrice = finalGasPrice
                //                if assembledTransaction.gasPrice == 0 {
                //                    if mergedOptions.gasPrice != nil {
                //                        assembledTransaction.gasPrice = mergedOptions.gasPrice!
                //                    } else {
                //                        assembledTransaction.gasPrice = gasPrice
                //                    }
                //                }
                return assembledTransaction
            }).done(on: queue) { tx in
                seal.fulfill(tx)
                }.catch(on: queue) { err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    /**
     *Send a prepared transaction to the blockchain. Internally checks the nonce for a sending account, assigns it, get a gas estimate and signs a transaction either locally or on the remote node.*
     
     - parameter password: Password for a private key if transaction is signed locally
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: Promise for TransactionResult which contains transaction hash and other info
     */
    public func sendPromise(password: String = "BANKEXFOUNDATION", options: Chain3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult> {
        let queue = chain3.requestDispatcher.queue
        return assemblePromise(options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            let mergedOptions = self.options.merge(with: options)
            var cleanedOptions = Chain3Options()
            cleanedOptions.from = mergedOptions.from
            cleanedOptions.to = mergedOptions.to
            return self.chain3.mc.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
        }
    }
    
    /**
     *Calls a function of the smart-contract and parses the returned data to native objects.*
     
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: Promise for Chain3Response from node
     */
    
    public func callPromise(options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<Chain3Response> {
        let assembledTransaction: LBRTransaction = transaction
        let queue = chain3.requestDispatcher.queue
        let returnPromise = Promise<Chain3Response> { seal in
            let mergedOptions = self.options.merge(with: options)
            var optionsForCall = Chain3Options()
            optionsForCall.from = mergedOptions.from
            optionsForCall.to = mergedOptions.to
            optionsForCall.value = mergedOptions.value
            let callPromise: Promise<Data> = self.chain3.mc.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
            callPromise.done(on: queue) { data in
                do {
                    if self.method == "fallback" {
                        let resultHex = data.toHexString().withHex
                        let response = Chain3Response(["result": resultHex as Any])
                        seal.fulfill(response)
                    } else {
                        print(data.toHexString())
                        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else {
                            throw Chain3Error.processingError("Can not decode returned parameters")
                        }
                        seal.fulfill(Chain3Response(decodedData))
                    }
                } catch {
                    seal.reject(error)
                }
                }.catch(on: queue) { err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    /**
     *Estimates gas required to execute the transaction. Setting a gas limit lower than the estimate will most likely result in a failed transaction. If this call returns an error it can also indicate that transaction is invalid as itself.*
     
     - parameter options: Chain3Options to override the previously assigned gas price, gas limit and value.
     - parameter onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.
     
     - returns: Promise for gas price
     */
    public func estimateGasPromise(options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        let assembledTransaction: LBRTransaction = self.transaction
        let queue = self.chain3.requestDispatcher.queue
        let returnPromise = Promise<BigUInt> { seal in
            let mergedOptions = self.options.merge(with: options)
            var optionsForGasEstimation = Chain3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let promise = self.chain3.mc.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            promise.done(on: queue) { (estimate: BigUInt) in
                seal.fulfill(estimate)
                }.catch(on: queue) { err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
}
