//
//  C3MC.swift
//  chain3swift
//
//  Created by Dmitry on 11/8/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

@objc public class C3MC: NSObject {
    public var swift: Chain3MC {
        return chain3.swift.mc
    }
    unowned var chain3: C3Chain3
    @objc public init(chain3: C3Chain3) {
        self.chain3 = chain3
    }
    /// Send an C3LBRTransaction object to the network. Transaction is either signed locally if there is a KeystoreManager
    /// object bound to the chain3 instance, or sent unsigned to the node. For local signing the password is required.
    ///
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// This function is synchronous!
    @objc public func sendTransaction(_ transaction: C3LBRTransaction, options: C3Options, password: String = "BANKEXFOUNDATION") throws -> C3TransactionSendingResult {
        return try swift.sendTransaction(transaction.swift, options: options.swift, password: password).objc
    }

    /// Send raw LBR transaction data to the network.
    ///
    /// This function is synchronous!
    @objc public func sendRawTransaction(data: Data) throws -> C3TransactionSendingResult {
        return try swift.sendRawTransaction(data).objc
    }

    /// Send raw LBR transaction data to the network by first serializing the C3LBRTransaction object.
    ///
    /// This function is synchronous!
    @objc public func sendRawTransaction(_ transaction: C3LBRTransaction) throws -> C3TransactionSendingResult {
        return try swift.sendRawTransaction(transaction.swift).objc
    }

    /// Returns a total number of transactions sent by the particular LBR address.
    ///
    /// "onBlock" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    @objc public func getTransactionCount(address: C3Address, onBlock: String = "latest") throws -> C3UInt {
        return try swift.getTransactionCount(address: address.swift, onBlock: onBlock).objc
    }

    /// Returns a balance of particular LBR address in Wei units (1 MC = 10^18 Sha).
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    @objc public func getBalance(address: C3Address, onBlock: String = "latest") throws -> C3UInt {
        return try swift.getBalance(address: address.swift, onBlock: onBlock).objc
    }

    /// Returns a block number of the last mined block that LBR node knows about.
    ///
    /// This function is synchronous!
    @objc public func getBlockNumber() throws -> C3UInt {
        return try swift.getBlockNumber().objc
    }

    /// Returns a current gas price in the units of Wei. The node has internal algorithms for averaging over the last few blocks.
    ///
    /// This function is synchronous!
    @objc public func getGasPrice() throws -> C3UInt {
        return try swift.getGasPrice().objc
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    @objc public func getTransactionDetails(txHash: Data) throws -> C3TransactionInBlock {
        return try swift.getTransactionDetails(txHash).objc
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getTransactionDetails(txHashString: String) throws -> C3TransactionInBlock {
        return try swift.getTransactionDetails(txHashString).objc
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getTransactionReceipt(txHash: Data) throws -> C3TransactionReceipt {
        return try swift.getTransactionReceipt(txHash).objc
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getTransactionReceipt(txHashString: String) throws -> C3TransactionReceipt {
        return try swift.getTransactionReceipt(txHashString).objc
    }

    /// Estimates a minimal amount of gas required to run a transaction. To do it the LBR node tries to run it and counts
    /// how much gas it consumes for computations. Setting the transaction gas limit lower than the estimate will most likely
    /// result in a failing transaction.
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    /// Error can also indicate that transaction is invalid in the current state, so formally it's gas limit is infinite.
    /// An example of such transaction can be sending an amount of MC that is larger than the current account balance.
    @objc public func estimateGas(_ transaction: C3LBRTransaction, options: C3Options?, onBlock: String = "latest") throws -> C3UInt {
        return try swift.estimateGas(transaction.swift, options: options?.swift, onBlock: onBlock).objc
    }

    /// Get a list of LBR accounts that a node knows about.
    /// If one has attached a Keystore Manager to the chain3 object it returns accounts known to the keystore.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getAccounts() throws -> [C3Address] {
        return try swift.getAccounts().map { $0.objc }
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded C3LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getBlockByHashString(_ hash: String, fullTransactions: Bool = false) throws -> C3Block {
        return try swift.getBlockByHash(hash, fullTransactions: fullTransactions).objc
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded C3LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) throws -> C3Block {
        return try swift.getBlockByHash(hash, fullTransactions: fullTransactions).objc
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded C3LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    @objc public func getBlock(byNumber: C3UInt, fullTransactions: Bool = false) throws -> C3Block {
        return try swift.getBlockByNumber(byNumber.swift, fullTransactions: fullTransactions).objc
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded C3LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    ///
    @objc public func getBlock(byString: String, fullTransactions: Bool = false) throws -> C3Block {
        return try swift.getBlockByNumber(byString, fullTransactions: fullTransactions).objc
    }

    /**
    Convenience wrapper to send LBR to another address. Internally it creates a virtual contract and encodes all the options and data.
    - Parameters:
    - to: C3Address to send funds to
    - amount: C3UInt indicating the amount in sha
    - extraData: Additional data to attach to the transaction
    - options: C3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead

    - returns:
    - C3TransactionIntermediate object

    */
    @objc public func sendMC(to: C3Address, amount: C3UInt, extraData: Data = Data(), options: C3Options? = nil) throws -> C3TransactionIntermediate {
        return try swift.sendMC(to: to.swift, amount: amount.swift, extraData: extraData, options: options?.swift).objc
    }

    @objc public func getBlockNumberPromise(completion: @escaping (C3UInt?,Error?)->()) {
        swift.getBlockNumberPromise()
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }

    @objc public func getGasPricePromise(completion: @escaping (C3UInt?,Error?)->()) {
        swift.getGasPricePromise()
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }


    @objc public func getBlockByHashPromise(_ hash: Data, fullTransactions: Bool, completion: @escaping (C3Block?,Error?)->()) {
        swift.getBlockByHashPromise(hash, fullTransactions: fullTransactions)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }

    @objc public func getTransactionDetailsPromise(_ txhash: Data, completion: @escaping (C3TransactionInBlock?,Error?)->()) {
        swift.getTransactionDetailsPromise(txhash)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }


    @objc public func getBalancePromise(address: C3Address, onBlock: String = "latest", completion: @escaping (C3UInt?,Error?)->()) {
        swift.getBalancePromise(address: address.swift, onBlock: onBlock)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }
    
    @objc public func getTransactionReceiptPromise(_ txhash: Data, completion: @escaping (C3TransactionReceipt?,Error?)->()) {
        swift.getTransactionReceiptPromise(txhash)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }

    @objc public func getBlock(byNumber: C3UInt, fullTransactions: Bool, completion: @escaping (C3Block?,Error?)->()) {
        swift.getBlockByNumberPromise(byNumber.swift, fullTransactions: fullTransactions)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }

    @objc public func getBlock(byString: String, fullTransactions: Bool, completion: @escaping (C3Block?,Error?)->()) {
        swift.getBlockByNumberPromise(byString, fullTransactions: fullTransactions)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }

    @objc public func getTransactionCountPromise(address: C3Address, onBlock: String = "latest", completion: @escaping (C3UInt?,Error?)->()) {
        swift.getTransactionCountPromise(address: address.swift, onBlock: onBlock)
            .done { completion($0.objc,nil) }
            .catch { completion(nil, $0) }
    }


    @objc public func getAccountsPromise(completion: @escaping ([C3Address]?,Error?)->()) {
        swift.getAccountsPromise()
            .done { completion($0.map { $0.objc },nil) }
            .catch { completion(nil, $0) }
    }
}
