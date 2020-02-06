//
//  C3Transaction.swift
//  chain3swift
//
//  Created by Dmitry on 11/9/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt

extension LBRTransaction {
    public var objc: C3LBRTransaction {
		return C3LBRTransaction(self)
	}
}
@objc public class C3LBRTransaction: NSObject, SwiftContainer {
	public var swift: LBRTransaction
	public required init(_ swift: LBRTransaction) {
		self.swift = swift
	}
	@objc public var nonce: C3UInt {
		get { return swift.nonce.objc }
		set { swift.nonce = newValue.swift }
	}
	@objc public var gasPrice: C3UInt {
		get { return swift.gasPrice.objc }
		set { swift.gasPrice = newValue.swift }
	}
	@objc public var gasLimit: C3UInt {
		get { return swift.gasLimit.objc }
		set { swift.gasLimit = newValue.swift }
	}
	@objc public var to: C3Address {
		get { return swift.to.objc }
		set { swift.to = newValue.swift }
	}
	@objc public var data: Data {
		get { return swift.data }
		set { swift.data = newValue }
	}
	@objc public var value: C3UInt {
		get { return swift.value.objc }
		set { swift.value = newValue.swift }
	}
	@objc public var v: C3UInt {
		get { return swift.v.objc }
		set { swift.v = newValue.swift }
	}
	@objc public var r: C3UInt {
		get { return swift.r.objc }
		set { swift.r = newValue.swift }
	}
	@objc public var s: C3UInt {
		get { return swift.s.objc }
		set { swift.s = newValue.swift }
	}
	
	@objc public var inferedChainID: C3NetworkId? {
		return swift.inferedChainID?.objc
	}
	
	@objc public var intrinsicChainID: C3UInt? {
		return swift.intrinsicChainID?.objc
	}
	
	@objc public func UNSAFE_setChainID(_ chainID: C3NetworkId?) {
		swift.UNSAFE_setChainID(chainID?.swift)
	}
	@objc public var transactionHash: Data? {
		return swift.hash
	}
	
	@objc public init(gasPrice: C3UInt, gasLimit: C3UInt, to: C3Address, value: C3UInt, data: Data) {
		swift = LBRTransaction(gasPrice: gasPrice.swift, gasLimit: gasLimit.swift, to: to.swift, value: value.swift, data: data)
	}
	
	@objc public init(to: C3Address, data: Data, options: C3Options) {
		swift = LBRTransaction(to: to.swift, data: data, options: options.swift)
	}
	
	@objc public init(nonce: C3UInt, gasPrice: C3UInt, gasLimit: C3UInt, to: C3Address, value: C3UInt, data: Data, v: C3UInt, r: C3UInt, s: C3UInt) {
		swift = LBRTransaction(nonce: nonce.swift, gasPrice: gasPrice.swift, gasLimit: gasLimit.swift, to: to.swift, value: value.swift, data: data, v: v.swift, r: r.swift, s: s.swift)
	}
	
	@objc public func mergedWithOptions(_ options: C3Options) -> C3LBRTransaction {
		return swift.mergedWithOptions(options.swift).objc
	}
	
	@objc public override var description: String {
		return swift.description
	}
	
	@objc public var sender: C3Address? {
		return swift.sender?.objc
	}
	
	@objc public func recoverPublicKey() -> Data? {
		return swift.recoverPublicKey()
	}
	
	@objc public var txhash: String? {
		return swift.txhash
	}
	
	@objc public var txid: String? {
		return swift.txid
	}
	
	@objc public func encode(forSignature: Bool = false, chainId: C3NetworkId? = nil) -> Data? {
		return swift.encode(forSignature: forSignature, chainId: chainId?.swift)
	}
	
	@objc public func encodeAsDictionary(from: C3Address? = nil) -> C3TransactionParameters? {
		return swift.encodeAsDictionary(from: from?.swift)?.objc
	}
	
	@objc public func hashForSignature(chainID: C3NetworkId? = nil) -> Data? {
		return swift.hashForSignature(chainID: chainID?.swift)
	}
	@objc public static func fromRaw(_ raw: Data) -> C3LBRTransaction? {
		return LBRTransaction.fromRaw(raw)?.objc
	}
}
