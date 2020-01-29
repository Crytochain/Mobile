//
//  Chain3+MC.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

/// Extension located
public class Chain3MC: Chain3OptionsInheritable {
    /// provider for some functions
    var provider: Chain3Provider
    unowned var chain3: Chain3
    public var options: Chain3Options {
        return chain3.options
    }
    
    public init(provider prov: Chain3Provider, chain3 chain3instance: Chain3) {
        provider = prov
        chain3 = chain3instance
    }
    /// Send a LBRTransaction object to the network. Transaction is either signed locally if there is a KeystoreManager
    /// object bound to the chain3 instance, or sent unsigned to the node. For local signing the password is required.
    ///
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// This function is synchronous!
    public func sendTransaction(_ transaction: LBRTransaction, options: Chain3Options, password: String = "BANKEXFOUNDATION") throws -> TransactionSendingResult {
        return try sendTransactionPromise(transaction, options: options, password: password).wait()
    }

    /// Performs a non-mutating "call" to some smart-contract. LBRTransaction bears all function parameters required for the call.
    /// Does NOT decode the data returned from the smart-contract.
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    func call(_ transaction: LBRTransaction, options: Chain3Options, onBlock: String = "latest") throws -> Data {
        return try callPromise(transaction, options: options, onBlock: onBlock).wait()
    }

    /// Send raw LBR transaction data to the network.
    ///
    /// This function is synchronous!
    public func sendRawTransaction(_ transaction: Data) throws -> TransactionSendingResult {
        return try sendRawTransactionPromise(transaction).wait()
    }

    /// Send raw LBR transaction data to the network by first serializing the LBRTransaction object.
    ///
    /// This function is synchronous!
    public func sendRawTransaction(_ transaction: LBRTransaction) throws -> TransactionSendingResult {
        return try sendRawTransactionPromise(transaction).wait()
    }

    /// Returns a total number of transactions sent by the particular LBR address.
    ///
    /// "onBlock" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    public func getTransactionCount(address: Address, onBlock: String = "latest") throws -> BigUInt {
        return try getTransactionCountPromise(address: address, onBlock: onBlock).wait()
    }

    /// Returns a balance of particular LBR address in Wei units (1 MC = 10^18 Sha).
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    public func getBalance(address: Address, onBlock: String = "latest") throws -> BigUInt {
        return try getBalancePromise(address: address, onBlock: onBlock).wait()
    }

    /// Returns a block number of the last mined block that LBR node knows about.
    ///
    /// This function is synchronous!
    public func getBlockNumber() throws -> BigUInt {
        return try getBlockNumberPromise().wait()
    }

    /// Returns a current gas price in the units of Wei. The node has internal algorithms for averaging over the last few blocks.
    ///
    /// This function is synchronous!
    public func getGasPrice() throws -> BigUInt {
        return try getGasPricePromise().wait()
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    public func getTransactionDetails(_ txhash: Data) throws -> TransactionInBlock {
        return try getTransactionDetailsPromise(txhash).wait()
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionDetails(_ txhash: String) throws -> TransactionInBlock {
        return try getTransactionDetailsPromise(txhash).wait()
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionReceipt(_ txhash: Data) throws -> TransactionReceipt {
        return try getTransactionReceiptPromise(txhash).wait()
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionReceipt(_ txhash: String) throws -> TransactionReceipt {
        return try getTransactionReceiptPromise(txhash).wait()
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
    public func estimateGas(_ transaction: LBRTransaction, options: Chain3Options?, onBlock: String = "latest") throws -> BigUInt {
        return try estimateGasPromise(transaction, options: options, onBlock: onBlock).wait()
    }

    /// Get a list of LBR accounts that a node knows about.
    /// If one has attached a Keystore Manager to the chain3 object it returns accounts known to the keystore.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getAccounts() throws -> [Address] {
        return try getAccountsPromise().wait()
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in LBR network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded LBRTransaction objects.
    ///
    /// This function is synchronous!
    ///
    ///
    public func getBlockByNumber(_ block: String, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByNumberPromise(block, fullTransactions: fullTransactions).wait()
    }

    /**
     Convenience wrapper to send LBR to another address. Internally it creates a virtual contract and encodes all the options and data.
     - Parameters:
     - to: Address to send funds to
     - amount: BigUInt indicating the amount in sha
     - extraData: Additional data to attach to the transaction
     - options: Chain3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead

     - returns:
     - TransactionIntermediate object

     */
    public func sendMC(to: Address, amount: BigUInt, extraData: Data = Data(), options: Chain3Options? = nil) throws -> TransactionIntermediate {
        let contract = try chain3.contract(Chain3Utils.coldWalletABI, at: to)
        var mergedOptions = self.options.merge(with: options)
        mergedOptions.value = amount
        return try contract.method("fallback", extraData: extraData, options: mergedOptions)
    }
    
    public func getBlockNumberPromise() -> Promise<BigUInt> {
        let request = JsonRpcRequestFabric.prepareRequest(.blockNumber, parameters: [])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    public func getGasPricePromise() -> Promise<BigUInt> {
        let request = JsonRpcRequestFabric.prepareRequest(.gasPrice, parameters: [])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    
    public func getBlockByHashPromise(_ hash: Data, fullTransactions: Bool = false) -> Promise<Block> {
        let hashString = hash.toHexString().withHex
        return getBlockByHashPromise(hashString, fullTransactions: fullTransactions)
    }
    
    public func getBlockByHashPromise(_ hash: String, fullTransactions: Bool = false) -> Promise<Block> {
        let request = JsonRpcRequestFabric.prepareRequest(.getBlockByHash, parameters: [hash, fullTransactions])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: Block = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    
    public func getTransactionDetailsPromise(_ txhash: Data) -> Promise<TransactionInBlock> {
        let hashString = txhash.toHexString().withHex
        return getTransactionDetailsPromise(hashString)
    }
    
    public func getTransactionDetailsPromise(_ txhash: String) -> Promise<TransactionInBlock> {
        let request = JsonRpcRequestFabric.prepareRequest(.getTransactionByHash, parameters: [txhash])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
//            let transactions = try container.decode([TransactionInBlock].self, forKey: .transactions)
//            self.transactions = transactions
            guard let value: TransactionInBlock = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    
    func sendTransactionPromise(_ transaction: LBRTransaction, options: Chain3Options, password: String = "BANKEXFOUNDATION") -> Promise<TransactionSendingResult> {
        //        print(transaction)
        var assembledTransaction: LBRTransaction = transaction.mergedWithOptions(options)
        let queue = chain3.requestDispatcher.queue
        do {
            if chain3.provider.attachedKeystoreManager == nil {
                guard let request = LBRTransaction.createRequest(method: .sendTransaction, transaction: assembledTransaction, onBlock: nil, options: options) else {
                    throw Chain3Error.processingError("Failed to create a request to send transaction")
                }
                return chain3.dispatch(request).map(on: queue) { response in
                    guard let value: String = response.getValue() else {
                        if response.error != nil {
                            throw Chain3Error.nodeError(response.error!.message)
                        }
                        throw Chain3Error.nodeError("Invalid value from LBR node")
                    }
                    let result = TransactionSendingResult(transaction: assembledTransaction, hash: value)
                    return result
                }
            }
            guard let from = options.from else {
                throw Chain3Error.inputError("No 'from' field provided")
            }
            do {
                try Chain3Signer.signTX(transaction: &assembledTransaction, keystore: chain3.provider.attachedKeystoreManager!, account: from, password: password)
            } catch {
                throw Chain3Error.inputError("Failed to locally sign a transaction")
            }
            return chain3.mc.sendRawTransactionPromise(assembledTransaction)
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    
    public func getBalancePromise(address: Address, onBlock: String = "latest") -> Promise<BigUInt> {
        let addr = address.address
        return getBalancePromise(address: addr, onBlock: onBlock)
    }
    
    public func getBalancePromise(address: String, onBlock: String = "latest") -> Promise<BigUInt> {
        let request = JsonRpcRequestFabric.prepareRequest(.getBalance, parameters: [address.lowercased(), onBlock])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    
    public func getTransactionReceiptPromise(_ txhash: Data) -> Promise<TransactionReceipt> {
        let hashString = txhash.toHexString().withHex
        return getTransactionReceiptPromise(hashString)
    }
    
    public func getTransactionReceiptPromise(_ txhash: String) -> Promise<TransactionReceipt> {
        let request = JsonRpcRequestFabric.prepareRequest(.getTransactionReceipt, parameters: [txhash])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: TransactionReceipt = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    func estimateGasPromise(_ transaction: LBRTransaction, options: Chain3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        let queue = chain3.requestDispatcher.queue
        do {
            guard let request = LBRTransaction.createRequest(method: .estimateGas, transaction: transaction, onBlock: onBlock, options: options) else {
                throw Chain3Error.processingError("Transaction is invalid")
            }
            let rp = chain3.dispatch(request)
            return rp.map(on: queue) { response in
                guard let value: BigUInt = response.getValue() else {
                    if response.error != nil {
                        throw Chain3Error.nodeError(response.error!.message)
                    }
                    throw Chain3Error.nodeError("Invalid value from LBR node")
                }
                return value
            }
        } catch {
            let returnPromise = Promise<BigUInt>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    
    public func getBlockByNumberPromise(_ number: UInt64, fullTransactions: Bool = false) -> Promise<Block> {
        let block = String(number, radix: 16).withHex
        return getBlockByNumberPromise(block, fullTransactions: fullTransactions)
    }
    
    public func getBlockByNumberPromise(_ number: BigUInt, fullTransactions: Bool = false) -> Promise<Block> {
        let block = String(number, radix: 16).withHex
        return getBlockByNumberPromise(block, fullTransactions: fullTransactions)
    }
    
    public func getBlockByNumberPromise(_ number: String, fullTransactions: Bool = false) -> Promise<Block> {
        let request = JsonRpcRequestFabric.prepareRequest(.getBlockByNumber, parameters: [number, fullTransactions])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: Block = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    func sendRawTransactionPromise(_ transaction: Data) -> Promise<TransactionSendingResult> {
        guard let deserializedTX =  LBRTransaction.fromRaw(transaction) else {
            let promise = Promise<TransactionSendingResult>.pending()
            promise.resolver.reject(Chain3Error.processingError("Serialized TX is invalid"))
            return promise.promise
        }
        return sendRawTransactionPromise(deserializedTX)
    }
    
    func sendRawTransactionPromise(_ transaction: LBRTransaction) -> Promise<TransactionSendingResult> {
        //        print(transaction)
        let queue = chain3.requestDispatcher.queue
        do {
            guard let request = LBRTransaction.createRawTransaction(transaction: transaction) else {
                throw Chain3Error.processingError("Transaction is invalid")
            }
            let rp = chain3.dispatch(request)
            return rp.map(on: queue) { response in
                guard let value: String = response.getValue() else {
                    if response.error != nil {
                        throw Chain3Error.nodeError(response.error!.message)
                    }
                    throw Chain3Error.nodeError("Invalid value from LBR node")
                }
                let result = TransactionSendingResult(transaction: transaction, hash: value)
                return result
            }
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    
    public func getTransactionCountPromise(address: Address, onBlock: String = "latest") -> Promise<BigUInt> {
        let addr = address.address
        return getTransactionCountPromise(address: addr, onBlock: onBlock)
    }
    
    public func getTransactionCountPromise(address: String, onBlock: String = "latest") -> Promise<BigUInt> {
        let request = JsonRpcRequestFabric.prepareRequest(.getTransactionCount, parameters: [address.lowercased(), onBlock])
        let rp = chain3.dispatch(request)
        let queue = chain3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    
    public func getAccountsPromise() -> Promise<[Address]> {
        let queue = chain3.requestDispatcher.queue
        if chain3.provider.attachedKeystoreManager != nil {
            let promise = Promise<[Address]>.pending()
            queue.async {
                do {
                    let accounts = try self.chain3.wallet.getAccounts()
                    promise.resolver.fulfill(accounts)
                } catch {
                    promise.resolver.reject(error)
                }
            }
            return promise.promise
        }
        let request = JsonRpcRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let rp = chain3.dispatch(request)
        return rp.map(on: queue) { response in
            guard let value: [Address] = response.getValue() else {
                if response.error != nil {
                    throw Chain3Error.nodeError(response.error!.message)
                }
                throw Chain3Error.nodeError("Invalid value from LBR node")
            }
            return value
        }
    }
    
    
    func callPromise(_ transaction: LBRTransaction, options: Chain3Options, onBlock: String = "latest") -> Promise<Data> {
        let queue = chain3.requestDispatcher.queue
        do {
            guard let request = LBRTransaction.createRequest(method: .call, transaction: transaction, onBlock: onBlock, options: options) else {
                throw Chain3Error.processingError("Transaction is invalid")
            }
            let rp = chain3.dispatch(request)
            return rp.map(on: queue) { response in
                guard let value: Data = response.getValue() else {
                    if response.error != nil {
                        throw Chain3Error.nodeError(response.error!.message)
                    }
                    throw Chain3Error.nodeError("Invalid value from LBR node")
                }
                return value
            }
        } catch {
            let returnPromise = Promise<Data>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
