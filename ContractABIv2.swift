//
//  ContractABIv2.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

public struct ContractV2: ContractProtocol {
    public var allEvents: [String] {
        return events.keys.compactMap({ (s) -> String in
            s
        })
    }

    public var allMethods: [String] {
        return methods.keys.compactMap({ (s) -> String in
            s
        })
    }

    public struct EventFilter {
        public var parameterName: String
        public var parameterValues: [AnyObject]
    }

    public var address: Address?
    var _abi: [ABIv2.Element]
    public var methods: [String: ABIv2.Element] {
        var toReturn = [String: ABIv2.Element]()
        for m in _abi {
            switch m {
            case let .function(function):
                guard let name = function.name else { continue }
                toReturn[name] = m
            default:
                continue
            }
        }
        return toReturn
    }

    public var constructor: ABIv2.Element? {
        var toReturn: ABIv2.Element?
        for m in _abi {
            if toReturn != nil {
                break
            }
            switch m {
            case .constructor:
                toReturn = m
                break
            default:
                continue
            }
        }
        if toReturn == nil {
            let defaultConstructor = ABIv2.Element.constructor(ABIv2.Element.Constructor(inputs: [], constant: false, payable: false))
            return defaultConstructor
        }
        return toReturn
    }

    public var events: [String: ABIv2.Element.Event] {
        var toReturn = [String: ABIv2.Element.Event]()
        for m in _abi {
            switch m {
            case let .event(event):
                let name = event.name
                toReturn[name] = event
            default:
                continue
            }
        }
        return toReturn
    }

    public var options: Chain3Options = .default

    public init(_ abiString: String, at address: Address? = nil) throws {
        let abi = try JSONDecoder().decode([ABIv2.Record].self, from: abiString.data)
        let abiNative = try abi.map({ (record) -> ABIv2.Element in
            try record.parse()
        })
        _abi = abiNative
        self.address = address
    }

    public init(abi: [ABIv2.Element]) {
        _abi = abi
    }

    public init(abi: [ABIv2.Element], at: Address) {
        _abi = abi
        address = at
    }

    public enum MethodError: Error {
        case noAddress
        case noGasLimit
        case noGasPrice
        case noConstructor
        case notFound
        case cannotEncodeDataWithGivenParameters
    }

    public func deploy(bytecode: Data, args: Any..., extraData: Data = Data(), options: Chain3Options?) throws -> LBRTransaction {
        return try deploy(bytecode: bytecode, parameters: args, extraData: extraData, options: options)
    }

    public func deploy(bytecode: Data, parameters: [Any], extraData: Data = Data(), options: Chain3Options?) throws -> LBRTransaction {
        let to: Address = .contractDeployment
        let options = self.options.merge(with: options)
        guard let gasLimit = options.gasLimit else { throw MethodError.noGasLimit }
        guard let gasPrice = options.gasPrice else { throw MethodError.noGasPrice }
        let value = options.value ?? 0

        guard let constructor = self.constructor else { throw MethodError.noConstructor }
        guard let encodedData = constructor.encodeParameters(parameters as [AnyObject]) else { throw MethodError.cannotEncodeDataWithGivenParameters }
        var fullData = bytecode
        if encodedData != Data() {
            fullData.append(encodedData)
        } else if extraData != Data() {
            fullData.append(extraData)
        }
        return LBRTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: fullData)
    }

    public func method(_ name: String, args: Any..., extraData: Data = Data(), options: Chain3Options?) throws -> LBRTransaction {
        return try method(name, parameters: args, extraData: extraData, options: options)
    }

    public func method(_ method: String, parameters: [Any], extraData: Data = Data(), options: Chain3Options?) throws -> LBRTransaction {
        var to: Address
        let options = self.options.merge(with: options)
        if let address = address {
            to = address
        } else if let address = options.to, address.isValid {
            to = address
        } else {
            throw MethodError.noAddress
        }
        guard let gasLimit = options.gasLimit else { throw MethodError.noGasLimit }
        guard let gasPrice = options.gasPrice else { throw MethodError.noGasPrice }
        let value = options.value ?? 0

        if method == "fallback" {
            return LBRTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: extraData)
        } else {
            guard let abiMethod = methods[method] else { throw MethodError.notFound }
            guard let encodedData = abiMethod.encodeParameters(parameters as [AnyObject]) else { throw MethodError.cannotEncodeDataWithGivenParameters }
            return LBRTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: encodedData)
        }
    }

    public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
        for (eName, ev) in events {
            if !ev.anonymous {
                if eventLog.topics[0] != ev.topic {
                    continue
                } else {
                    let parsed = ev.decodeReturnedLogs(eventLog)
                    if parsed != nil {
                        return (eName, parsed!)
                    }
                }
            } else {
                let parsed = ev.decodeReturnedLogs(eventLog)
                if parsed != nil {
                    return (eName, parsed!)
                }
            }
        }
        return (nil, nil)
    }

    public func testBloomForEventPrecence(eventName: String, bloom: LBRBloomFilter) -> Bool? {
        guard let event = events[eventName] else { return nil }
        if event.anonymous {
            return true
        }
        let eventOfSuchTypeIsPresent = bloom.test(topic: event.topic)
        return eventOfSuchTypeIsPresent
    }

    public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
        guard method != "fallback" else { return [:] }
        guard let function = methods[method] else { return nil }
        guard case .function = function else { return nil }
        return function.decodeReturnData(data)
    }

    public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
        guard method != "fallback" else { return nil }
        guard let function = methods[method] else { return nil }
        switch function {
        case .function:
            return function.decodeInputData(data)
        case .constructor:
            return function.decodeInputData(data)
        default:
            return nil
        }
    }

    public func decodeInputData(_ data: Data) -> [String: Any]? {
        guard data.count % 32 == 4 else { return nil }
        let methodSignature = data[0 ..< 4]
        let foundFunction = _abi.filter { (m) -> Bool in
            switch m {
            case let .function(function):
                return function.methodEncoding == methodSignature
            default:
                return false
            }
        }
        guard foundFunction.count == 1 else {
            return nil
        }
        let function = foundFunction[0]
        return function.decodeInputData(Data(data[4 ..< data.count]))
    }
}
