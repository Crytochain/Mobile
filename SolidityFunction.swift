//
//  SolidityFunction.swift
//  chain3swift
//
//  Created by Dmitry on 12/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

public protocol SolidityDataRepresentable {
    var solidityData: Data { get }
    var isSolidityBinaryType: Bool { get }
}
public extension SolidityDataRepresentable {
    var isSolidityBinaryType: Bool { return false }
}

extension BinaryInteger {
    public var solidityData: Data { return BigInt(self).abiEncode(bits: 256) }
    
}
extension Int: SolidityDataRepresentable {}
extension Int8: SolidityDataRepresentable {}
extension Int16: SolidityDataRepresentable {}
extension Int32: SolidityDataRepresentable {}
extension Int64: SolidityDataRepresentable {}
extension BigInt: SolidityDataRepresentable {}
extension UInt: SolidityDataRepresentable {}
extension UInt8: SolidityDataRepresentable {}
extension UInt16: SolidityDataRepresentable {}
extension UInt32: SolidityDataRepresentable {}
extension UInt64: SolidityDataRepresentable {}
extension BigUInt: SolidityDataRepresentable {}
extension Address: SolidityDataRepresentable {
    public var solidityData: Data { return addressData.setLengthLeft(32)! }
}
extension Data: SolidityDataRepresentable {
    public var solidityData: Data { return self }
    public var isSolidityBinaryType: Bool { return true }
}
extension String: SolidityDataRepresentable {
    public var solidityData: Data { return data }
    public var isSolidityBinaryType: Bool { return true }
}
extension Array: SolidityDataRepresentable where Element == SolidityDataRepresentable {
    public var solidityData: Data {
        var data = Data(capacity: 32 * count)
        for element in self {
            data.append(element.solidityData)
        }
        return data
    }
    
//    func dynamicSolidityData() -> Data {
//        var data = Data(capacity: 32 * (count+1))
//        data.append(count.solidityData)
//        for element in self {
//            data.append(element.solidityData)
//        }
//        return data
//    }
//    func staticSolidityData(count: Int) -> Data {
//        let capacity = 32 * count
//        var data = Data(capacity: capacity)
//        for element in self {
//            data.append(element.solidityData)
//        }
//        if data.count < capacity {
//            data.append(Data(count: capacity - data.count))
//        }
//        return data
//    }
    func data(function: String) -> Data {
        var data = Data(capacity: count * 32 + 4)
        data.append(function.keccak256()[0..<4])
        for element in self {
            data.append(element.solidityData)
        }
        return data
    }
}

extension Address {
    public func assemble(_ function: String, _ arguments: [Any], chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "pending") -> Promise<LBRTransaction> {
        let options = chain3.options.merge(with: options)
        
        let function = try! SolidityFunction(function: function)
        let data = function.encode(arguments as! [SolidityDataRepresentable])
        var assembledTransaction = LBRTransaction(to: self, data: data, options: options)
        let queue = chain3.requestDispatcher.queue
        let returnPromise = Promise<LBRTransaction> { seal in
            guard let from = options.from else {
                seal.reject(Chain3Error.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = Chain3Options()
            optionsForGasEstimation.from = options.from
            optionsForGasEstimation.to = options.to
            optionsForGasEstimation.value = options.value
            let getNoncePromise = chain3.mc.getTransactionCountPromise(address: from, onBlock: onBlock)
            let gasEstimatePromise = chain3.mc.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            let gasPricePromise = chain3.mc.getGasPricePromise()
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
                let estimate = Chain3Options.smartMergeGasLimit(originalOptions: options, extraOptions: options, gasEstimate: gasEstimate)
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                let finalGasPrice = Chain3Options.smartMergeGasPrice(originalOptions: options, extraOptions: options, priceEstimate: gasPrice)
                assembledTransaction.gasPrice = finalGasPrice
                return assembledTransaction
            }).done(on: queue, seal.fulfill).catch(on: queue, seal.reject)
        }
        return returnPromise
    }
    
    public func send(_ function: String, _ arguments: Any..., password: String = "BANKEXFOUNDATION", chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult> {
        return send(function, arguments, password: password, chain3: chain3, options: options, onBlock: onBlock)
    }
    public func send(_ function: String, _ arguments: [Any], password: String = "BANKEXFOUNDATION", chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult> {
        let options = chain3.options.merge(with: options)
        let queue = chain3.requestDispatcher.queue
        return assemble(function, arguments, chain3: chain3, options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            var cleanedOptions = Chain3Options()
            cleanedOptions.from = options.from
            cleanedOptions.to = options.to
            return chain3.mc.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
        }
    }
    public func call(_ function: String, _ arguments: Any..., chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<Chain3DataResponse> {
        return call(function, arguments, chain3: chain3, options: options, onBlock: onBlock)
    }
    public func call(_ function: String, _ arguments: [Any], chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<Chain3DataResponse> {
        let options = chain3.options.merge(with: options)
        let function = try! SolidityFunction(function: function)
        let data = function.encode(arguments as! [SolidityDataRepresentable])
        let assembledTransaction = LBRTransaction(to: self, data: data, options: options)
        let queue = chain3.requestDispatcher.queue
        return Promise<Chain3DataResponse> { seal in
            var optionsForCall = Chain3Options()
            optionsForCall.from = options.from
            optionsForCall.to = options.to
            optionsForCall.value = options.value
            chain3.mc.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
                .done(on: queue) { seal.fulfill(Chain3DataResponse($0)) }
                .catch(on: queue, seal.reject)
        }
    }
    
    public func estimateGas(_ function: String, _ arguments: Any..., chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        return estimateGas(function, arguments, chain3: chain3, options: options, onBlock: onBlock)
    }
    public func estimateGas(_ function: String, _ arguments: [Any], chain3: Chain3 = .default, options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        let options = chain3.options.merge(with: options)
        let function = try! SolidityFunction(function: function)
        let data = function.encode(arguments as! [SolidityDataRepresentable])
        let assembledTransaction = LBRTransaction(to: self, data: data, options: options)
        let queue = chain3.requestDispatcher.queue
        return Promise<BigUInt> { seal in
            var optionsForGasEstimation = Chain3Options()
            optionsForGasEstimation.from = options.from
            optionsForGasEstimation.to = options.to
            optionsForGasEstimation.value = options.value
            chain3.mc.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
                .done(on: queue, seal.fulfill)
                .catch(on: queue, seal.reject)
        }
    }
}
