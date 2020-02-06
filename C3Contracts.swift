//
//  C3Contracts.swift
//  chain3swift
//
//  Created by Dmitry on 11/8/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt

protocol C3OptionsInheritable: class {
    var _swiftOptions: Chain3Options { get set }
}

/// Options for sending or calling a particular LBR transaction

// MARK:- ERC20
@objc public class C3ERC20: NSObject, SwiftBridgeable {
	public var swift: ERC20 {
		let contract = ERC20(address.swift)
		contract.options = options.swift
		contract.password = password
		return contract
	}
	@objc public let address: C3Address
	@objc public var options: C3Options = .default
	@objc public var password: String = "BANKEXFOUNDATION"
	@objc public var gasPrice: C3ERC20GasPrice { return C3ERC20GasPrice(self) }
	
	@objc public init(address: C3Address) {
		self.address = address
	}
	@objc public init(address: C3Address, from: C3Address, password: String) {
		self.address = address
		self.options.from = from
		self.password = password
	}
	@objc public func name() throws -> String {
		return try swift.name()
	}
	@objc public func symbol() throws -> String {
		return try swift.symbol()
	}
	@objc public func totalSupply() throws -> C3UInt {
		return try swift.totalSupply().objc
	}
	@objc public func decimals() throws -> C3UInt {
		return try swift.decimals().objc
	}
	@objc public func balance(of user: C3Address) throws -> C3UInt {
		return try swift.balance(of: user.swift).objc
	}
	@objc public func naturalBalance(of user: C3Address) throws -> String {
		return try swift.naturalBalance(of: user.swift)
	}
	
	@objc public func allowance(from owner: C3Address, to spender: C3Address) throws -> C3UInt {
		return try swift.allowance(from: owner.swift, to: spender.swift).objc
	}
	
	@objc public func transfer(to user: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.transfer(to: user.swift, amount: amount.swift).objc
	}
	
	@objc public func approve(to user: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.approve(to: user.swift, amount: amount.swift).objc
	}
	
	
	@objc public func transferFrom(owner: C3Address, to: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.transferFrom(owner: owner.swift, to: to.swift, amount: amount.swift).objc
	}
	
	@objc public func transfer(to user: C3Address, naturalUnits: C3NaturalUnits) throws -> C3TransactionSendingResult {
		return try swift.transfer(to: user.swift, amount: naturalUnits.swift).objc
	}
	
	@objc public func approve(to user: C3Address, naturalUnits: C3NaturalUnits) throws -> C3TransactionSendingResult {
		return try swift.approve(to: user.swift, amount: naturalUnits.swift).objc
	}
	
	@objc public func transferFrom(owner: C3Address, to: C3Address, naturalUnits: C3NaturalUnits) throws -> C3TransactionSendingResult {
		return try swift.transferFrom(owner: owner.swift, to: to.swift, amount: naturalUnits.swift).objc
	}
}

@objc public class C3ERC20GasPrice: NSObject {
	let contract: C3ERC20
	init(_ contract: C3ERC20) {
		self.contract = contract
	}
	
	@objc public func transfer(to user: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.transfer(to: user.swift, amount: amount.swift).objc
	}
	@objc public func approve(to user: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.approve(to: user.swift, amount: amount.swift).objc
	}
	@objc public func transferFrom(owner: C3Address, to: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.transferFrom(owner: owner.swift, to: to.swift, amount: amount.swift).objc
	}
	@objc public func transfer(to user: C3Address, naturalUnits: C3NaturalUnits) throws -> C3UInt {
		return try contract.swift.gasPrice.transfer(to: user.swift, amount: naturalUnits.swift).objc
	}
	
	@objc public func approve(to user: C3Address, naturalUnits: C3NaturalUnits) throws -> C3UInt {
		return try contract.swift.gasPrice.approve(to: user.swift, amount: naturalUnits.swift).objc
	}
	
	/// contract owner only
	/// transfers from owner to recepient
	@objc public func transferFrom(owner: C3Address, to: C3Address, naturalUnits: C3NaturalUnits) throws -> C3UInt {
		return try contract.swift.gasPrice.transferFrom(owner: owner.swift, to: to.swift, amount: naturalUnits.swift).objc
	}
}


// MARK:- ERC721
@objc public class C3ERC721: NSObject {
	public var swift: ERC721 {
		let contract = ERC721(address.swift)
		contract.options = options.swift
		contract.password = password
		return contract
	}
	@objc public let address: C3Address
	@objc public var options: C3Options = .default
	@objc public var password: String = "BANKEXFOUNDATION"
	@objc public var gasPrice: C3ERC721GasPrice { return C3ERC721GasPrice(self) }
	
	@objc public init(address: C3Address) {
		self.address = address
	}
	@objc public init(address: C3Address, from: C3Address, password: String) {
		self.address = address
		self.options.from = from
		self.password = password
	}
	
	@objc public func balance(of user: C3Address) throws -> C3UInt {
		return try swift.balance(of: user.swift).objc
	}
	/// - returns: address of token holder
	@objc public func owner(of token: C3UInt) throws -> C3Address {
		return try swift.owner(of: token.swift).objc
	}
	
	/// Sending approve that another user can take your token
	@objc public func approve(to user: C3Address, token: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.approve(to: user.swift, token: token.swift).objc
	}
	
	/// - returns: address
	@objc public func approved(for token: C3UInt) throws -> C3Address {
		return try swift.approved(for: token.swift).objc
	}
	/// sets operator for all your tokens
	@objc public func setApproveForAll(operator: C3Address, approved: Bool) throws -> C3TransactionSendingResult {
		return try swift.setApproveForAll(operator: `operator`.swift, approved: approved).objc
	}
	/// checks if user is approved to manager your tokens
	/// returns bool
	@objc public func isApprovedForAll(owner: C3Address, operator: C3Address) throws -> NSNumber {
		return try swift.isApprovedForAll(owner: owner.swift, operator: `operator`.swift) as NSNumber
	}
	/// transfers token from one address to another
	/// - important: admin only
	@objc public func transfer(from: C3Address, to: C3Address, token: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.transfer(from: from.swift, to: to.swift, token: token.swift).objc
	}
	
	@objc public func safeTransfer(from: C3Address, to: C3Address, token: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.safeTransfer(from: from.swift, to: to.swift, token: token.swift).objc
	}
}
	
/**
Gas price functions for erc721 token requests
*/
@objc public class C3ERC721GasPrice: NSObject {
	let contract: C3ERC721
	init(_ contract: C3ERC721) {
		self.contract = contract
	}
	
	/// - returns: gas price for approve(address,uint256) transaction
	@objc public func approve(to user: C3Address, token: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.approve(to: user.swift, token: token.swift).objc
	}
	/// - returns: gas price for setApprovalForAll(address,bool) transaction
	@objc public func setApproveForAll(operator: C3Address, approved: Bool) throws -> C3UInt {
		return try contract.swift.gasPrice.setApproveForAll(operator: `operator`.swift, approved: approved).objc
	}
	/// - returns: gas price for transferFrom(address,address,uint256) transaction
	@objc public func transfer(from: C3Address, to: C3Address, token: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.transfer(from: from.swift, to: to.swift, token: token.swift).objc
	}
	/// - returns: gas price for safeTransferFrom(address,address,uint256) transaction
	@objc public func safeTransfer(from: C3Address, to: C3Address, token: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.safeTransfer(from: from.swift, to: to.swift, token: token.swift).objc
	}
}


// MARK:- ERC777

@objc public class C3ERC777: NSObject {
	public var swift: ERC777 {
		let contract = ERC777(address.swift)
		contract.options = options.swift
		contract.password = password
		return contract
	}
	@objc public let address: C3Address
	@objc public var options: C3Options = .default
	@objc public var password: String = "BANKEXFOUNDATION"
	@objc public var gasPrice: C3ERC777GasPrice { return C3ERC777GasPrice(self) }
	
	@objc public init(address: C3Address) {
		self.address = address
	}
	@objc public init(address: C3Address, from: C3Address, password: String) {
		self.address = address
		self.options.from = from
		self.password = password
	}
	
	@objc public func name() throws -> String {
		return try swift.name()
	}
	@objc public func symbol() throws -> String {
		return try swift.symbol()
	}
	@objc public func totalSupply() throws -> C3UInt {
		return try swift.totalSupply().objc
	}
	@objc public func decimals() throws -> C3UInt {
		return try swift.decimals().objc
	}
	@objc public func balance(of user: C3Address) throws -> C3UInt {
		return try swift.balance(of: user.swift).objc
	}
	
	@objc public func allowance(from owner: C3Address, to spender: C3Address) throws -> C3UInt {
		return try swift.allowance(from: owner.swift, to: spender.swift).objc
	}
	@objc public func transfer(to user: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.transfer(to: user.swift, amount: amount.swift).objc
	}
	@objc public func approve(to user: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.approve(to: user.swift, amount: amount.swift).objc
	}
	@objc public func transfer(from: C3Address, to: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.transfer(from: from.swift, to: to.swift, amount: amount.swift).objc
	}
	
	@objc public func send(to user: C3Address, amount: C3UInt) throws -> C3TransactionSendingResult {
		return try swift.send(to: user.swift, amount: amount.swift).objc
	}
	@objc public func send(to user: C3Address, amount: C3UInt, userData: Data) throws -> C3TransactionSendingResult {
		return try swift.send(to: user.swift, amount: amount.swift, userData: userData).objc
	}
	
	@objc public func authorize(operator user: C3Address) throws -> C3TransactionSendingResult {
		return try swift.authorize(operator: user.swift).objc
	}
	@objc public func revoke(operator user: C3Address) throws -> C3TransactionSendingResult {
		return try swift.revoke(operator: user.swift).objc
	}
	
	@objc public func isOperatorFor(operator user: C3Address, tokenHolder: C3Address) throws -> NSNumber {
		return try swift.isOperatorFor(operator: user.swift, tokenHolder: tokenHolder.swift) as NSNumber
	}
	@objc public func operatorSend(from: C3Address, to: C3Address, amount: C3UInt, userData: Data) throws -> C3TransactionSendingResult {
		return try swift.operatorSend(from: from.swift, to: to.swift, amount: amount.swift, userData: userData).objc
	}
}

@objc public class C3ERC777GasPrice: NSObject {
	let contract: C3ERC777
	init(_ contract: C3ERC777) {
		self.contract = contract
	}
	
	/// - returns: gas price for transfer(address,uint256) transaction
	@objc public func transfer(to user: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.transfer(to: user.swift, amount: amount.swift).objc
	}
	/// - returns: gas price for approve(address,uint256) transaction
	@objc public func approve(to user: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.approve(to: user.swift, amount: amount.swift).objc
	}
	/// - returns: gas price for transferFrom(address,address,uint256) transaction
	@objc public func transfer(from: C3Address, to: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.transfer(from: from.swift, to: to.swift, amount: amount.swift).objc
	}
	
	/// - returns: gas price for send(address,uint256) transaction
	@objc public func send(to user: C3Address, amount: C3UInt) throws -> C3UInt {
		return try contract.swift.gasPrice.send(to: user.swift, amount: amount.swift).objc
	}
	/// - returns: gas price for send(address,uint256,bytes) transaction
	@objc public func send(to user: C3Address, amount: C3UInt, userData: Data) throws -> C3UInt {
		return try contract.swift.gasPrice.send(to: user.swift, amount: amount.swift, userData: userData).objc
	}
	
	/// - returns: gas price for authorizeOperator(address) transaction
	@objc public func authorize(operator user: C3Address) throws -> C3UInt {
		return try contract.swift.gasPrice.authorize(operator: user.swift).objc
	}
	/// - returns: gas price for revokeOperator(address) transaction
	@objc public func revoke(operator user: C3Address) throws -> C3UInt {
		return try contract.swift.gasPrice.revoke(operator: user.swift).objc
	}
	
	/// - returns: gas price for operatorSend(address,address,uint256,bytes) transaction
	@objc public func operatorSend(from: C3Address, to: C3Address, amount: C3UInt, userData: Data) throws -> C3UInt {
		return try contract.swift.gasPrice.operatorSend(from: from.swift, to: to.swift, amount: amount.swift, userData: userData).objc
	}
}
