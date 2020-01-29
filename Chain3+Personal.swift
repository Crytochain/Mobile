//
//  Chain3+Personal.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 14.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

/// Personal functions
public class Chain3Personal: Chain3OptionsInheritable {
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
    /**
     *Locally or remotely sign a message (arbitrary data) with the private key. To avoid potential signing of a transaction the message is first prepended by a special header and then hashed.*

     - parameter message: Message Data
     - parameter from: Use a private key that corresponds to this account
     - parameter password: Password for account if signing locally
     - returns: signed message data
     - important: This call is synchronous

     */
    public func signPersonalMessage(message: Data, from: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        return try signPersonalMessagePromise(message: message, from: from, password: password).wait()
    }

    /**
     *Unlock an account on the remote node to be able to send transactions and sign messages.*

     - parameter account: Address of the account to unlock
     - parameter password: Password to use for the account
     - parameter seconds: Time inteval before automatic account lock by LBR node
     - returns: isUnlocked
     - important: This call is synchronous. Does nothing if private keys are stored locally.

     */
    public func unlockAccount(account: Address, password _: String = "BANKEXFOUNDATION", seconds _: UInt64 = 300) throws -> Bool {
        return try unlockAccountPromise(account: account).wait()
    }

    /**
     *Recovers a signer of some message. Message is first prepended by special prefix (check the "signPersonalMessage" method description) and then hashed.*
     
     - parameter personalMessage: Message Data
     - parameter signature: Serialized signature, 65 bytes
     - returns: signer address

     */
    public func ecrecover(personalMessage: Data, signature: Data) throws -> Address {
        return try Chain3Utils.personalECRecover(personalMessage, signature: signature)
    }

    /**
     *Recovers a signer of some hash. Checking what is under this hash is on behalf of the user.*
     
     - parameter hash: Signed hash
     - parameter signature: Serialized signature, 65 bytes
     - returns: signer address

     */
    public func ecrecover(hash: Data, signature: Data) throws -> Address {
        return try Chain3Utils.hashECRecover(hash: hash, signature: signature)
    }
    
    func signPersonalMessagePromise(message: Data, from: Address, password: String = "BANKEXFOUNDATION") -> Promise<Data> {
        let queue = chain3.requestDispatcher.queue
        do {
            if chain3.provider.attachedKeystoreManager == nil {
                let hexData = message.toHexString().withHex
                let request = JsonRpcRequestFabric.prepareRequest(.personalSign, parameters: [from.address.lowercased(), hexData])
                return chain3.dispatch(request).map(on: queue) { response in
                    guard let value: Data = response.getValue() else {
                        if response.error != nil {
                            throw Chain3Error.nodeError(response.error!.message)
                        }
                        throw Chain3Error.nodeError("Invalid value from LBR node")
                    }
                    return value
                }
            }
            let signature = try Chain3Signer.signPersonalMessage(message, keystore: chain3.provider.attachedKeystoreManager!, account: from, password: password)
            let returnPromise = Promise<Data>.pending()
            queue.async {
                returnPromise.resolver.fulfill(signature)
            }
            return returnPromise.promise
        } catch {
            let returnPromise = Promise<Data>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
    
    func unlockAccountPromise(account: Address, password: String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Promise<Bool> {
        let addr = account.address
        return unlockAccountPromise(account: addr, password: password, seconds: seconds)
    }
    
    func unlockAccountPromise(account: String, password: String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Promise<Bool> {
        let queue = chain3.requestDispatcher.queue
        do {
            if chain3.provider.attachedKeystoreManager == nil {
                let request = JsonRpcRequestFabric.prepareRequest(.unlockAccount, parameters: [account.lowercased(), password, seconds])
                return chain3.dispatch(request).map(on: queue) { response in
                    guard let value: Bool = response.getValue() else {
                        if response.error != nil {
                            throw Chain3Error.nodeError(response.error!.message)
                        }
                        throw Chain3Error.nodeError("Invalid value from LBR node")
                    }
                    return value
                }
            }
            throw Chain3Error.inputError("Can not unlock a local keystore")
        } catch {
            let returnPromise = Promise<Bool>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
    
}
