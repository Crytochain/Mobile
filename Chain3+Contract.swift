
//  Chain3+Contract.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

extension Chain3 {
    /// The contract instance. Initialized in runtime from ABI string (that is a JSON array). In addition an existing contract address can be supplied to provide the default "to" address in all the following requests. ABI version is 2 by default and should not be changed.
    public func contract(_ abiString: String, at: Address? = nil) throws -> Chain3Contract {
        return try Chain3Contract(chain3: self, abiString: abiString, at: at, options: options)
    }
}

/// Chain3 instance bound contract instance.
public class Chain3Contract {
    var contract: ContractProtocol
    var chain3: Chain3
    public var options: Chain3Options
    
    /// Initialize the bound contract instance by supplying the Chain3 provider bound object, ABI, LBR address and some default
    /// options for further function calls. By default the contract inherits options from the chain3 object. Additionally supplied "options"
    /// do override inherited ones.
    public init(chain3 chain3Instance: Chain3, abiString: String, at: Address? = nil, options: Chain3Options? = nil) throws {
        chain3 = chain3Instance
        self.options = chain3.options.merge(with: options)
        contract = try ContractV2(abiString, at: at)
        if at != nil {
            contract.address = at
            self.options.to = at
        } else if let addr = self.options.to {
            contract.address = addr
        }
    }
    
    /// Deploys a constact instance using the previously provided (at initialization) ABI, some bytecode, constructor parameters and options.
    /// If extraData is supplied it is appended to encoded bytecode and constructor parameters.
    ///
    /// Returns a "Transaction intermediate" object.
    public func deploy(bytecode: Data, args: Any..., extraData: Data = Data(), options: Chain3Options?) throws -> TransactionIntermediate {
        return try deploy(bytecode: bytecode, parameters: args, extraData: extraData, options: options)
    }
    
    public func deploy(bytecode: Data, parameters: [Any], extraData: Data = Data(), options: Chain3Options?) throws -> TransactionIntermediate {
        let mergedOptions = self.options.merge(with: options)
        var tx = try contract.deploy(bytecode: bytecode, parameters: parameters, extraData: extraData, options: mergedOptions)
        tx.chainID = chain3.provider.network
        return TransactionIntermediate(transaction: tx, chain3: chain3, contract: contract, method: "fallback", options: mergedOptions)
    }
    
    /// Creates and object responsible for calling a particular function of the contract. If method name is not found in ABI - returns nil.
    /// If extraData is supplied it is appended to encoded function parameters. Can be usefull if one wants to call
    /// the function not listed in ABI. "Parameters" should be an array corresponding to the list of parameters of the function.
    /// Elements of "parameters" can be other arrays or instances of String, Data, BigInt, BigUInt, Int or Address.
    ///
    /// Returns a "Transaction intermediate" object.
    public func method(_ name: String = "fallback", args: Any..., extraData: Data = Data(), options: Chain3Options?) throws -> TransactionIntermediate {
        return try method(name, parameters: args, extraData: extraData, options: options)
    }
    
    public func method(_ method: String = "fallback", parameters: [Any], extraData: Data = Data(), options: Chain3Options?) throws -> TransactionIntermediate {
        let mergedOptions = self.options.merge(with: options)
        var tx = try contract.method(method, parameters: parameters, extraData: extraData, options: mergedOptions)
        tx.chainID = chain3.provider.network
        return TransactionIntermediate(transaction: tx, chain3: chain3, contract: contract, method: method, options: mergedOptions)
    }
    
    /// Parses an EventLog object by using a description from the contract's ABI.
    public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
        return contract.parseEvent(eventLog)
    }
    
    /// Creates an "EventParserProtocol" compliant object to use it for parsing particular block or transaction for events.
    public func createEventParser(_ eventName: String, filter: EventFilter?) -> EventParserProtocol? {
        return EventParser(chain3: chain3, eventName: eventName, contract: contract, filter: filter)
    }
}
