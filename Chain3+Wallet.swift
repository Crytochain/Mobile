//
//  Chain3+HookedWallet.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import BigInt

public enum Chain3WalletError: Error {
    case attachadKeystoreNotFound
    case noAccounts
}

/// Wallet functions
public class Chain3Wallet {
    /// provider for some functions
    var provider: Chain3Provider
    unowned var chain3: Chain3
    public init(provider prov: Chain3Provider, chain3 chain3instance: Chain3) {
        provider = prov
        chain3 = chain3instance
    }
    
    /// - throws: Chain3WalletError.attachadKeystoreNotFound
    public func getAccounts() throws -> [Address] {
        guard let keystoreManager = self.chain3.provider.attachedKeystoreManager else { throw Chain3WalletError.attachadKeystoreNotFound }
        return keystoreManager.addresses
    }

    /// - throws:
    /// Chain3WalletError.attachadKeystoreNotFound
    /// Chain3WalletError.noAccounts
    public func getCoinbase() throws -> Address {
        let accounts = try getAccounts()
        guard let account = accounts.first else { throw Chain3WalletError.noAccounts }
        return account
    }

    /// - throws:
    /// Chain3WalletError.attachadKeystoreNotFound
    /// AbstractKeystoreError
    /// Error
    public func signTX(transaction: inout LBRTransaction, account: Address, password: String = "BANKEXFOUNDATION") throws {
        guard let keystoreManager = self.chain3.provider.attachedKeystoreManager else { throw Chain3WalletError.attachadKeystoreNotFound }
        try Chain3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
    }

    
    /// - throws:
    /// DataError.hexStringCorrupted(String)
    /// Chain3WalletError.attachadKeystoreNotFound
    public func signPersonalMessage(_ personalMessage: String, account: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        let data = try personalMessage.dataFromHex()
        return try signPersonalMessage(data, account: account, password: password)
    }

    /// - throws: SECP256K1Error
    public func signPersonalMessage(_ personalMessage: Data, account: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        guard let keystoreManager = self.chain3.provider.attachedKeystoreManager else { throw Chain3WalletError.attachadKeystoreNotFound }
        return try Chain3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password)
    }
}
