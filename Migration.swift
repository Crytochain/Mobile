//
//  Merge.swift
//  chain3swift-iOS
//
//  Created by Dmitry on 29/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt


/// TIP
/// To quickly fix all renamed functions you can do:
/// 1. (cmd + ') to jump to next issue
/// 2. (ctrl + alt + cmd + f) to fix all issues in current file
/// 3. repeat

/// chain3swift 2.0 changes

@available (*, deprecated: 2.0, renamed: "JsonRpcRequest")
public typealias JSONRPCrequest = JsonRpcRequest
@available (*, deprecated: 2.0, renamed: "JsonRpcParams")
public typealias JSONRPCparams = JsonRpcParams
@available (*, deprecated: 2.0, renamed: "JsonRpcRequestFabric")
public typealias JSONRPCRequestFabric = JsonRpcRequestFabric
@available (*, deprecated: 2.0, renamed: "JsonRpcResponse")
public typealias JSONRPCresponse = JsonRpcResponse
@available (*, deprecated: 2.0, renamed: "JsonRpcResponseBatch")
public typealias JSONRPCresponseBatch = JsonRpcResponseBatch
@available (*, deprecated: 2.0, renamed: "Address")
public typealias LBRAddress = Address

public extension Chain3 {
    typealias EIP67Code = chain3swift.EIP67Code
    typealias EIP67CodeGenerator = chain3swift.EIP67CodeGenerator
    typealias EIP67CodeParser = chain3swift.EIP67CodeParser
    @available (*, deprecated: 2.0, message: "Use Chain3Units")
    typealias Units = Chain3Units
    // @available (*, deprecated: 2.0, message: "Use Chain3Utils")
    // i'll leave it here
    typealias Utils = Chain3Utils
    @available (*, deprecated: 2.0, message: "Use Chain3MC")
    typealias MC = Chain3MC
    @available (*, deprecated: 2.0, message: "Use Chain3MC")
    typealias Personal = Chain3Personal
    @available (*, deprecated: 2.0, message: "Use Chain3MC")
    typealias BrowserFunctions = Chain3BrowserFunctions
    typealias Chain3Wallet = chain3swift.Chain3Wallet

    @available (*, deprecated: 2.0, message: "use Chain3(url: URL)")
    static func new(_ providerURL: URL) -> Chain3? {
        guard let provider = Chain3HttpProvider(providerURL) else { return nil }
        return Chain3(provider: provider)
    }

    /// Initialized Chain3 instance bound to Gateway's mainnet provider.
    @available (*, deprecated: 2.0, message: "use Chain3(gateway: .mainnet, accessToken: String?)")
    static func GatewayMainnetChain3(accessToken: String? = nil) -> Chain3 {
        let gateway = GatewayProvider(.mainnet, accessToken: accessToken)!
        return Chain3(provider: gateway)
    }

    /// Initialized Chain3 instance bound to Gateway's rinkeby provider.
    @available (*, deprecated: 2.0, message: "use Chain3(gateway: .rinkeby, accessToken: String?)")
    static func GatewayRinkebyChain3(accessToken: String? = nil) -> Chain3 {
        let gateway = GatewayProvider(.rinkeby, accessToken: accessToken)!
        return Chain3(provider: gateway)
    }

    /// Initialized Chain3 instance bound to Gateway's ropsten provider.
    @available (*, deprecated: 2.0, message: "use Chain3(gateway: .ropsten, accessToken: String?)")
    static func GatewayRopstenChain3(accessToken: String? = nil) -> Chain3 {
        let gateway = GatewayProvider(.ropsten, accessToken: accessToken)!
        return Chain3(provider: gateway)
    }
}

public extension Chain3MC {
    @available(*, unavailable, message: "Use sendMC with BigUInt(\"1.01\",units: .mc)")
    public func sendMC(to _: Address, amount _: String, units _: Chain3Units = .mc, extraData _: Data = Data(), options _: Chain3Options? = nil) throws -> TransactionIntermediate { fatalError() }

    @available(*, unavailable, message: "Use sendMC BigUInt(\"some\",units: .mc)")
    public func sendMC(from _: Address, to _: Address, amount _: String, units _: Chain3Units = .mc, extraData _: Data = Data(), options _: Chain3Options? = nil) -> TransactionIntermediate? { fatalError() }

    @available(*, unavailable, message: "Use ERC20 class instead")
    public func sendERC20tokensWithKnownDecimals(tokenAddress _: Address, from _: Address, to _: Address, amount _: BigUInt, options _: Chain3Options? = nil) throws -> TransactionIntermediate {
        fatalError("")
    }

    @available(*, unavailable, message: "Use ERC20 class instead")
    public func sendERC20tokensWithNaturalUnits(tokenAddress _: Address, from _: Address, to _: Address, amount _: String, options _: Chain3Options? = nil) throws -> TransactionIntermediate {
        fatalError("")
    }
}

extension Chain3Utils {
    @available(*,deprecated: 2.0,message: "Use number.string(units:decimals:decimalSeparator:options:)")
    public static func formatToLBRUnits(_ bigNumber: BigInt, toUnits: Chain3Units = .mc, decimals: Int = 4, decimalSeparator: String = ".") -> String {
        return bigNumber.string(units: toUnits, decimals: decimals, decimalSeparator: decimalSeparator)
    }
    @available(*,deprecated: 2.0,message: "Use number.string(unitDecimals:formattingDecimals:decimalSeparator:options:)")
    public static func formatToPrecision(_ bigNumber: BigInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        var options = BigUInt.StringOptions.default
        if fallbackToScientific {
            options.insert(.fallbackToScientific)
        }
        return bigNumber.string(unitDecimals: numberDecimals, decimals: formattingDecimals, decimalSeparator: decimalSeparator, options: options)
    }
    @available(*,deprecated: 2.0,message: "Use number.string(units:formattingDecimals:decimalSeparator:options:)")
    public static func formatToLBRUnits(_ bigNumber: BigUInt, toUnits: Chain3Units = .mc, decimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        var options = BigUInt.StringOptions.default
        if fallbackToScientific {
            options.insert(.fallbackToScientific)
        }
        return bigNumber.string(units: toUnits, decimals: decimals, decimalSeparator: decimalSeparator, options: options)
    }
    @available(*,deprecated: 2.0,message: "Use number.string(unitDecimals:formattingDecimals:decimalSeparator:options:)")
    public static func formatToPrecision(_ bigNumber: BigUInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        var options = BigUInt.StringOptions.default
        if fallbackToScientific {
            options.insert(.fallbackToScientific)
        }
        return bigNumber.string(unitDecimals: numberDecimals, decimals: formattingDecimals, decimalSeparator: decimalSeparator, options: options)
    }
}

public extension Chain3Options {
    @available(*, deprecated: 2.0, message: "renamed to .default")
    public static func defaultOptions() -> Chain3Options { return .default }
}


public struct BIP39 {
    @available(*, unavailable, message: "Use try Mnemonics(entropy:language:)")
    public static func generateMnemonicsFromEntropy(entropy: Data, language: BIP39Language = BIP39Language.english) -> String? {
        fatalError()
    }

    @available(*, unavailable, message: "Use Mnemonics(entropySize:language:)")
    public static func generateMnemonics(bitsOfEntropy: Int, language: BIP39Language = BIP39Language.english) -> String? {
        fatalError()
    }

    @available(*,deprecated: 2.0,message: "Use Mnemonics().entropy")
    public static func mnemonicsToEntropy(_ mnemonics: String, language: BIP39Language = BIP39Language.english) -> Data? {
        fatalError()
    }

    @available(*,deprecated: 2.0,message: "Use Mnemonics().seed(password:)")
    public static func seedFromMmemonics(_ mnemonics: String, password: String = "", language: BIP39Language = BIP39Language.english) -> Data? {
        fatalError()
    }
}

extension EIP67Code {
    @available (*, deprecated: 2.0, message: "Use init with address")
    public init(address: String) {
        self.init(address: Address(address))
    }
}
extension KeystoreManager {
    @available (*, deprecated: 2.0, renamed: "default")
    static var defaultManager: KeystoreManager? {
        return KeystoreManager.default
    }
}

extension Chain3 {
    @available (*, deprecated: 2.0, message: "Renamed Chain3.chain3contract to Chain3Contract")
    typealias chain3contract = Chain3Contract
}

extension BIP32Keystore {
    @available (*, deprecated: 2.0, message: "Use init with Mnemonics")
    public convenience init(mnemonics: String, password: String = "BANKEXFOUNDATION", mnemonicsPassword: String = "", language: BIP39Language = .english, prefixPath: String = HDNode.defaultPathMetamaskPrefix) throws {
        let mnemonics = try Mnemonics(mnemonics, language: language)
        mnemonics.password = mnemonicsPassword
        try self.init(mnemonics: mnemonics, password: password, prefixPath: prefixPath)
    }
}
