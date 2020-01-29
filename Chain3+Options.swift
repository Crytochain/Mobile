//
//  Chain3+Options.swift
//  chain3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

public protocol Chain3OptionsInheritable {
    var options: Chain3Options { get }
}

/// Options for sending or calling a particular LBR transaction
public struct Chain3Options {
    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil.
    public var to: Address?
    /// Sets from what account a transaction should be sent. Used only internally as the sender of LBR transaction
    /// is determined purely from the transaction signature. Indicates to the LBR node or to the local keystore what private key
    /// should be used to sign a transaction.
    ///
    /// Can be nil if one reads the information from the blockchain.
    public var from: Address?
    /// Sets the gas limit for a transaction.
    ///
    /// If set to nil it's usually determined automatically.
    public var gasLimit: BigUInt?
    /// Sets the gas price for a transaction.
    ///
    /// If set to nil it's usually determined automatically.
    public var gasPrice: BigUInt?
    /// Sets the value (amount of Wei) sent along the transaction.
    ///
    /// If set to nil it's equal to zero
    public var value: BigUInt?
    
    public var systemContract: BigUInt?
    
    public var shardingFlag: BigUInt?
    
    public var via: Address?
    
    /// inits Chain3Options with all nil parameters
    public init() {}

    /// Default options filler. Sets gas limit, gas price and value to zeroes.
    public static var `default`: Chain3Options {
        var options = Chain3Options()
        options.gasLimit = BigUInt(0)
        options.gasPrice = BigUInt(0)
        options.value = BigUInt(0)
        options.shardingFlag = BigUInt(0)
        options.systemContract = BigUInt(0)
        options.via = Address("0x")
        return options
    }
    
    /// Inits Chain3Options from dictionary
    public init(_ json: [String: Any]) throws {
        gasLimit = try json.at("gas").uint256()
        gasPrice = try json.at("gasPrice").uint256()
        value = try json.at("value").uint256()
        from = try json.at("from").address()
        shardingFlag = try json.at("shardingFlag").uint256()
        systemContract = try json.at("syscnt").uint256()
    }

    /// Merges two sets of opions by overriding the parameters from the first set by parameters from the second
    /// set if those are not nil.
    ///
    /// Returns default options if both parameters are nil.
    public func merge(with options: Chain3Options?) -> Chain3Options {
        guard let old = options else { return self }
        var new = self
        merge(&new.to, old.to)
        merge(&new.from, old.from)
        merge(&new.gasLimit, old.gasLimit)
        merge(&new.gasPrice, old.gasPrice)
        merge(&new.value, old.value)
        merge(&new.shardingFlag, old.shardingFlag)
        merge(&new.systemContract, old.systemContract)
        merge(&new.via, old.via)
        return new
    }

    private func merge<T>(_ to: inout T?, _ from: T?) {
        guard let from = from else { return }
        to = from
    }

    /// merges two sets of options along with a gas estimate to try to guess the final gas limit value required by user.
    ///
    /// Please refer to the source code for a logic.
    public static func smartMergeGasLimit(originalOptions: Chain3Options?, extraOptions: Chain3Options?, gasEstimate: BigUInt) -> BigUInt {
        let originalOptions = originalOptions ?? .default
        let mergedOptions = originalOptions.merge(with: extraOptions)
        if mergedOptions.gasLimit == nil {
            return gasEstimate // for user's convenience we just use an estimate
//            return nil // there is no opinion from user, so we can not proceed
        } else {
            if originalOptions.gasLimit != nil && originalOptions.gasLimit! < gasEstimate { // original gas estimate was less than what's required, so we check extra options
                if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimate {
                    return extraOptions!.gasLimit!
                } else {
                    return gasEstimate // for user's convenience we just use an estimate
//                    return nil // estimate is lower than allowed
                }
            } else {
                if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimate {
                    return extraOptions!.gasLimit!
                } else {
                    return gasEstimate // for user's convenience we just use an estimate
                    //                    return nil // estimate is lower than allowed
                }
            }
        }
    }

    /// merges two sets of options along with a gas estimate to try to guess the final gas price value required by user.
    ///
    /// Please refer to the source code for a logic.
    public static func smartMergeGasPrice(originalOptions: Chain3Options?, extraOptions: Chain3Options?, priceEstimate: BigUInt) -> BigUInt {
        let originalOptions = originalOptions ?? .default
        let mergedOptions = originalOptions.merge(with: extraOptions)
        if mergedOptions.gasPrice == nil {
            return priceEstimate
        } else if mergedOptions.gasPrice == 0 {
            return priceEstimate
        } else {
            return mergedOptions.gasPrice!
        }
    }
}
