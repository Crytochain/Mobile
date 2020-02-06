//
//  TransactionSigner.swift
//  chain3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

public enum TransactionSignerError: Error {
    case signatureError(String)
}

public struct Chain3Signer {
    /**
     Signs transaction. Uses ERP155Signer if you specified chainID otherwise it uses FallbackSigner
     - parameter transaction: transaction to sign
     - parameter keystore: keystore that stores account private key
     - parameter account: account that signs message
     - parameter password: password to decrypt private key
     - parameter useExtraEntropy: add random data to signed message. default: false
     - throws: Chain3UtilsError.cannotConvertDataToAscii, SECP256K1Error, AbstractKeystoreError
     */
    public static func signTX(transaction: inout LBRTransaction, keystore: AbstractKeystore, account: Address, password: String, useExtraEntropy: Bool = false) throws {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        if transaction.chainID != nil {
            try EIP155Signer.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        } else {
            try FallbackSigner.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        }
    }

    /**
     Signs transaction
     - parameter intermediate: transaction to sign
     - parameter keystore: keystore that stores account private key
     - parameter account: account that signs message
     - parameter password: password to decrypt private key
     - parameter useExtraEntropy: add random data to signed message. default: false
     - throws: Chain3UtilsError.cannotConvertDataToAscii, SECP256K1Error, AbstractKeystoreError
     */
    public static func signIntermediate(intermediate: inout TransactionIntermediate, keystore: AbstractKeystore, account: Address, password: String, useExtraEntropy: Bool = false) throws {
        var tx = intermediate.transaction
        try Chain3Signer.signTX(transaction: &tx, keystore: keystore, account: account, password: password, useExtraEntropy: useExtraEntropy)
        intermediate.transaction = tx
    }

    /**
     Signs personal message
     - parameter personalMessage: message data
     - parameter keystore: keystore that stores account private key
     - parameter account: account that signs message
     - parameter password: password to decrypt private key
     - parameter useExtraEntropy: add random data to signed message. default: false
     - throws: Chain3UtilsError.cannotConvertDataToAscii, SECP256K1Error, AbstractKeystoreError
     */
    public static func signPersonalMessage(_ personalMessage: Data, keystore: AbstractKeystore, account: Address, password: String, useExtraEntropy: Bool = false) throws -> Data {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        let hash = try Chain3Utils.hashPersonalMessage(personalMessage)
        return try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy).serializedSignature
    }

    public struct EIP155Signer {
        public static func sign(transaction: inout LBRTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            for _ in 0 ..< 1024 {
                do {
                    try attemptSignature(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
                    return
                } catch {}
            }
            throw AbstractKeystoreError.invalidAccountError
        }

        public enum Error: Swift.Error {
            case chainIdNotFound
            case hashNotFound
            case recoveredPublicKeyCorrupted
        }

        private static func attemptSignature(transaction: inout LBRTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            guard let chainID = transaction.chainID else { throw Error.chainIdNotFound }
            guard let hash = transaction.hashForSignature(chainID: chainID) else { throw Error.hashNotFound }
            let signature = try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            let unmarshalledSignature = try SECP256K1.unmarshalSignature(signatureData: signature.serializedSignature)
            let originalPublicKey = try SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.v = BigUInt(unmarshalledSignature.v) + 35 + chainID.rawValue + chainID.rawValue
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            guard originalPublicKey.constantTimeComparisonTo(recoveredPublicKey) else { throw Error.recoveredPublicKeyCorrupted }
        }
    }

    public struct FallbackSigner {
        public static func sign(transaction: inout LBRTransaction, privateKey: Data, useExtraEntropy _: Bool = false) throws {
            for _ in 0 ..< 1024 {
                do {
                    try attemptSignature(transaction: &transaction, privateKey: privateKey)
                    return
                } catch {}
            }
            throw AbstractKeystoreError.invalidAccountError
        }

        public enum Error: Swift.Error {
            case hashNotFound
            case recoveredPublicKeyCorrupted
        }
        
        private static func attemptSignature(transaction: inout LBRTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            guard let hash = transaction.hashForSignature(chainID: nil) else { throw Error.hashNotFound }
            let signature = try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            let unmarshalledSignature = try SECP256K1.unmarshalSignature(signatureData: signature.serializedSignature)
            let originalPublicKey = try SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.chainID = nil
            transaction.v = BigUInt(unmarshalledSignature.v) + BigUInt(27)
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            guard originalPublicKey.constantTimeComparisonTo(recoveredPublicKey) else { throw Error.recoveredPublicKeyCorrupted }
        }
    }
}
