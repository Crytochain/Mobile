//
//  C3Structs.swift
//  chain3swift
//
//  Created by Dmitry on 11/8/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

var opt: ObjcError {
	return .returnsOptionalValue
}
enum ObjcError: Error {
	case returnsOptionalValue
}

extension Address {
    public var objc: C3Address {
        return C3Address(self)
    }
}

extension Address.AddressType {
    public var objc: C3AddressType {
        switch self {
        case .normal: return .normal
        case .contractDeployment: return .contractDeployment
        }
    }
}
@objc public enum C3AddressType: Int, SwiftBridgeable {
	case normal, contractDeployment
	public var swift: Address.AddressType {
		switch self {
		case .normal: return .normal
		case .contractDeployment: return .contractDeployment
		}
	}
}

@objc public class C3Address: NSObject, SwiftContainer {
    public var swift: Address
    public required init(_ swift: Address) {
		self.swift = swift
	}
	@objc public init(string: String, type: C3AddressType = .normal) {
		swift = Address(string, type: type.swift)
	}
	@objc public init(data: Data, type: C3AddressType = .normal) {
		swift = Address(data, type: type.swift)
	}
	@objc public var isValid: Bool {
		return swift.isValid
	}
	@objc public var type: C3AddressType {
		get { return swift.type.objc }
		set { swift.type = newValue.swift }
	}
	@objc public var addressData: Data {
		return swift.addressData
	}
	@objc public var address: String {
		return swift.address
	}
	
	@objc public static func toChecksumAddress(_ addr: String) -> String? {
		return Address.toChecksumAddress(addr)
	}
	
	@objc public func check() throws {
		try swift.check()
	}
	
	@objc public static var contractDeployment: C3Address {
		return Address.contractDeployment.objc
	}
	@objc public override var description: String {
		return swift.description
	}
}

@objc public extension NSString {
	var isContractAddress: Bool {
		return Data(hex: self as String).count > 0
	}
	
	var isAddress: Bool {
		return Data(hex: self as String).count == 20
	}
	
	var contractAddress: C3Address {
		return C3Address(string: self as String, type: .contractDeployment)
	}
}

extension Chain3Options {
    public var objc: C3Options {
		return C3Options(self)
	}
}
@objc public class C3Options: NSObject, SwiftContainer {
	weak var object: C3OptionsInheritable?
	var options: Chain3Options!
    public var swift: Chain3Options {
		get { return object?._swiftOptions ?? options }
		set {
			if let object = object {
				object._swiftOptions = newValue
			} else {
				options = newValue
			}
		}
	}
	@objc public var to: C3Address? {
		get { return swift.to?.objc }
		set { swift.to = newValue?.swift }
	}
	@objc public var from: C3Address? {
		get { return swift.from?.objc }
		set { swift.from = newValue?.swift }
	}
	@objc public var gasLimit: C3UInt? {
		get { return swift.gasLimit?.objc }
		set { swift.gasLimit = newValue?.swift }
	}
	@objc public var gasPrice: C3UInt? {
		get { return swift.gasPrice?.objc }
		set { swift.gasPrice = newValue?.swift }
	}
	@objc public var value: C3UInt? {
		get { return swift.value?.objc }
		set { swift.value = newValue?.swift }
	}
	
	
	init(object: C3OptionsInheritable) {
		self.object = object
	}
	public required init(_ swift: Chain3Options) {
		self.options = swift
	}
	@objc public override init() {
		self.options = Chain3Options()
	}
	@objc public static var `default`: C3Options {
		return Chain3Options.default.objc
	}
	
	@objc public init(_ json: [String: Any]) throws {
		self.options = try Chain3Options(json)
	}
	
	/// merges two sets of options along with a gas estimate to try to guess the final gas limit value required by user.
	///
	/// Please refer to the source code for a logic.
	@objc public static func smartMergeGasLimit(originalOptions: C3Options?, extraOptions: C3Options?, gasEstimate: C3UInt) -> C3UInt {
		return Chain3Options.smartMergeGasLimit(originalOptions: originalOptions?.swift, extraOptions: extraOptions?.swift, gasEstimate: gasEstimate.swift).objc
	}
	
	@objc public static func smartMergeGasPrice(originalOptions: C3Options?, extraOptions: C3Options?, priceEstimate: C3UInt) -> C3UInt {
		return Chain3Options.smartMergeGasPrice(originalOptions: originalOptions?.swift, extraOptions: extraOptions?.swift, priceEstimate: priceEstimate.swift).objc
	}
}

extension NetworkId {
    public var objc: C3NetworkId {
		return C3NetworkId(self.rawValue.objc)
	}
}
@objc public class C3NetworkId: NSObject, SwiftBridgeable {
	public var swift: NetworkId {
		return NetworkId(rawValue: rawValue.swift)
	}
	typealias IntegerLiteralType = Int
	@objc public var rawValue: C3UInt
	@objc public required init(rawValue: C3UInt) {
		self.rawValue = rawValue
	}
	
	@objc public init(_ rawValue: C3UInt) {
		self.rawValue = rawValue
	}
	
	@objc public var all: [C3NetworkId] {
		return [.mainnet, .ropsten, .rinkeby, .kovan]
	}
	
	@objc public static var `default`: C3NetworkId = .mainnet
	@objc public static var mainnet: C3NetworkId { return NetworkId.mainnet.objc }
	@objc public static var ropsten: C3NetworkId { return NetworkId.ropsten.objc }
	@objc public static var rinkeby: C3NetworkId { return NetworkId.rinkeby.objc }
	@objc public static var kovan: C3NetworkId { return NetworkId.kovan.objc }
	@objc public override var description: String {
		return swift.description
	}
}

extension TransactionSendingResult {
    public var objc: C3TransactionSendingResult {
		return C3TransactionSendingResult(transaction: transaction.objc, hash: hash)
	}
}
@objc public class C3TransactionSendingResult: NSObject, SwiftBridgeable {
    public var swift: TransactionSendingResult {
        return TransactionSendingResult(transaction: transaction.swift, hash: transactionHash)
    }
    
	@objc public var transaction: C3LBRTransaction
	@objc public var transactionHash: String
	@objc public init(transaction: C3LBRTransaction, hash: String) {
		self.transaction = transaction
		self.transactionHash = hash
	}
}

extension TransactionParameters {
    public var objc: C3TransactionParameters {
		return C3TransactionParameters(self)
	}
}
@objc public class C3TransactionParameters: NSObject, SwiftContainer {
	public var swift: TransactionParameters {
		var parameters = TransactionParameters(from: from, to: to)
		parameters.data = data
		parameters.gas = gas
		parameters.gasPrice = gasPrice
		parameters.value = value
		return parameters
	}
	public required init(_ swift: TransactionParameters) {
		data = swift.data
		from = swift.from
		gas = swift.gas
		gasPrice = swift.gasPrice
		to = swift.to
		value = swift.value
	}
	/// transaction parameters
	@objc public var data: String?
	/// transaction sender
	@objc public var from: String?
	/// gas limit
	@objc public var gas: String?
	/// gas price
	@objc public var gasPrice: String?
	/// transaction recipient
	@objc public var to: String?
	/// LBR value
	@objc public var value: String? = "0x0"
	
	/// init with sender and recipient
	@objc public init(from _from: String?, to _to: String?) {
		from = _from
		to = _to
	}
}


extension TransactionDetails {
    public var objc: C3TransactionDetails {
		return C3TransactionDetails(self)
	}
}
@objc public class C3TransactionDetails: NSObject, SwiftContainer {
	public let swift: TransactionDetails
	public required init(_ swift: TransactionDetails) {
		self.swift = swift
	}
	
	@objc public var blockHash: Data? {
		return swift.blockHash
	}
	@objc public var blockNumber: C3UInt? {
		return swift.blockNumber?.objc
	}
	@objc public var transactionIndex: C3UInt? {
		return swift.transactionIndex?.objc
	}
	@objc public var transaction: C3LBRTransaction {
		return swift.transaction.objc
	}
}

extension TransactionReceipt {
    public var objc: C3TransactionReceipt {
		return C3TransactionReceipt(self)
	}
}
@objc public class C3TransactionReceipt: NSObject, SwiftContainer {
	public let swift: TransactionReceipt
	public required init(_ swift: TransactionReceipt) {
		self.swift = swift
	}
	@objc public var transactionHash: Data {
		return swift.transactionHash
	}
	@objc public var blockHash: Data {
		return swift.blockHash
	}
	@objc public var blockNumber: C3UInt {
		return swift.blockNumber.objc
	}
	@objc public var transactionIndex: C3UInt {
		return swift.transactionIndex.objc
	}
	@objc public var contractAddress: C3Address? {
		return swift.contractAddress?.objc
	}
	@objc public var cumulativeGasUsed: C3UInt {
		return swift.cumulativeGasUsed.objc
	}
	@objc public var gasUsed: C3UInt {
		return swift.gasUsed.objc
	}
	@objc public var logs: [C3EventLog] {
		return swift.logs.map { $0.objc }
	}
	@objc public var status: C3TXStatus {
		return swift.status.objc
	}
	@objc public var logsBloom: C3LBRBloomFilter? {
		return swift.logsBloom?.objc
	}
	
}
extension TransactionReceipt.TXStatus {
    public var objc: C3TXStatus {
		switch self {
		case .ok: return .ok
		case .failed: return .failed
		case .notYetProcessed: return .notYetProcessed
		}
	}
}
@objc public enum C3TXStatus: Int, SwiftBridgeable {
	case ok
	case failed
	case notYetProcessed
    public var swift: TransactionReceipt.TXStatus {
        switch self {
        case .ok: return .ok
        case .failed: return .failed
        case .notYetProcessed: return .notYetProcessed
        }
    }
}

extension EventLog {
    public var objc: C3EventLog {
		return C3EventLog(self)
	}
}
@objc public class C3EventLog: NSObject, SwiftContainer {
	public let swift: EventLog
	public required init(_ swift: EventLog) {
		self.swift = swift
	}
	@objc public var address: C3Address {
		return swift.address.objc
	}
	@objc public var blockHash: Data {
		return swift.blockHash
	}
	@objc public var blockNumber: C3UInt {
		return swift.blockNumber.objc
	}
	@objc public var data: Data {
		return swift.data
	}
	@objc public var logIndex: C3UInt {
		return swift.logIndex.objc
	}
	@objc public var removed: Bool {
		return swift.removed
	}
	@objc public var topics: [Data] {
		return swift.topics
	}
	@objc public var transactionHash: Data {
		return swift.transactionHash
	}
	@objc public var transactionIndex: C3UInt {
		return swift.transactionIndex.objc
	}
	
}


extension TransactionInBlock {
    public var objc: C3TransactionInBlock {
		return C3TransactionInBlock(self)
	}
}
@objc public class C3TransactionInBlock: NSObject, SwiftContainer {
    public var swift: TransactionInBlock {
        if let hash = transactionHash {
            return .hash(hash)
        } else if let transaction = transaction {
            return .transaction(transaction.swift)
        } else {
            return .null
        }
    }
	public required init(_ swift: TransactionInBlock) {
		switch swift {
		case let .hash(data):
			transactionHash = data
		case let .transaction(transaction):
			self.transaction = transaction.objc
		case .null: break
		}
	}
	
	var transactionHash: Data?
	var transaction: C3LBRTransaction?
}


extension Block {
    public var objc: C3Block {
		return C3Block(self)
	}
}
@objc public class C3Block: NSObject, SwiftContainer {
	public let swift: Block
	public required init(_ swift: Block) {
		self.swift = swift
	}
	
	@objc public var number: C3UInt {
		return swift.number.objc
	}
	@objc public var blockHash: Data {
		return swift.hash
	}
	@objc public var parentHash: Data {
		return swift.parentHash
	}
	@objc public var nonce: Data? {
		return swift.nonce
	}
	@objc public var sha3Uncles: Data {
		return swift.sha3Uncles
	}
	@objc public var logsBloom: C3LBRBloomFilter? {
		return swift.logsBloom?.objc
	}
	@objc public var transactionsRoot: Data {
		return swift.transactionsRoot
	}
	@objc public var stateRoot: Data {
		return swift.stateRoot
	}
	@objc public var receiptsRoot: Data {
		return swift.receiptsRoot
	}
	@objc public var miner: C3Address? {
		return swift.miner?.objc
	}
	@objc public var difficulty: C3UInt {
		return swift.difficulty.objc
	}
	@objc public var totalDifficulty: C3UInt {
		return swift.totalDifficulty.objc
	}
	@objc public var extraData: Data {
		return swift.extraData
	}
	@objc public var size: C3UInt {
		return swift.size.objc
	}
	@objc public var gasLimit: C3UInt {
		return swift.gasLimit.objc
	}
	@objc public var gasUsed: C3UInt {
		return swift.gasUsed.objc
	}
	@objc public var timestamp: Date {
		return swift.timestamp
	}
	@objc public var transactions: [C3TransactionInBlock] {
		return swift.transactions.map { $0.objc }
	}
	@objc public var uncles: [Data] {
		return swift.uncles
	}
}


extension EventParserResult {
    public var objc: C3EventParserResult {
		return C3EventParserResult(self)
	}
}
extension EventParserResultProtocol {
    public var objc: C3EventParserResult {
		return (self as! EventParserResult).objc
	}
}
@objc public class C3EventParserResult: NSObject, SwiftContainer {
	public let swift: EventParserResult
	public required init(_ swift: EventParserResult) {
		self.swift = swift
	}
	
	@objc public var eventName: String {
		return swift.eventName
	}
	@objc public var transactionReceipt: C3TransactionReceipt? {
		return swift.transactionReceipt?.objc
	}
	@objc public var contractAddress: C3Address {
		return swift.contractAddress.objc
	}
	@objc public var decodedResult: [String: Any] {
		return swift.decodedResult
	}
	@objc public var eventLog: C3EventLog? {
		return swift.eventLog?.objc
	}
}

extension LBRBloomFilter {
    public var objc: C3LBRBloomFilter {
		return C3LBRBloomFilter(self)
	}
}

@objc public class C3LBRBloomFilter: NSObject, SwiftContainer {
	public let swift: LBRBloomFilter
	public required init(_ swift: LBRBloomFilter) {
		self.swift = swift
	}
	
	@objc public var bytes: Data {
		return swift.bytes
	}
	@objc public func asBigUInt() -> C3UInt {
		return swift.asBigUInt().objc
	}
}
