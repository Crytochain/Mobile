//
//  LBRKeystoreV3.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 18.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import CryptoSwift
import Foundation

public class LBRKeystoreV3: AbstractKeystore {
    // Class

    public func getAddress() -> Address? {
        return address
    }

    // Protocol

    public var addresses: [Address] {
        guard let address = address else { return [] }
        return [address]
    }

    public var isHDKeystore: Bool = false

    /// throws AbstractKeystoreError.invalidPasswordError
    /// throws AbstractKeystoreError.invalidAccountError
    public func UNSAFE_getPrivateKeyData(password: String, account: Address) throws -> Data {
        if addresses.count == 1 && account == addresses.last {
            guard let pk = try? self.getKeyData(password) else { throw AbstractKeystoreError.invalidPasswordError }
            guard let privateKey = pk else { throw AbstractKeystoreError.invalidAccountError }
            return privateKey
        }
        throw AbstractKeystoreError.invalidAccountError
    }

    // --------------
    private var address: Address?
    public var keystoreParams: KeystoreParamsV3?

    public convenience init?(_ jsonString: String) {
        self.init(jsonString.lowercased().data)
    }

    public convenience init?(_ jsonData: Data) {
        guard let keystoreParams = try? JSONDecoder().decode(KeystoreParamsV3.self, from: jsonData) else { return nil }
        self.init(keystoreParams)
    }

    public init?(_ keystoreParams: KeystoreParamsV3) {
        if keystoreParams.version != 3 { return nil }
        if keystoreParams.crypto.version != nil && keystoreParams.crypto.version != "1" { return nil }
        self.keystoreParams = keystoreParams
        if keystoreParams.address != nil {
            address = Address(keystoreParams.address!.withHex)
        } else {
            return nil
        }
    }

    public init? (password: String = "BANKEXFOUNDATION", aesMode: String = "aes-128-cbc") throws {
        var newPrivateKey = Data.random(length: 32)
        defer { Data.zero(&newPrivateKey) }
        try encryptDataToStorage(password, keyData: newPrivateKey, aesMode: aesMode)
    }

    public init? (privateKey: Data, password: String = "BANKEXFOUNDATION", aesMode: String = "aes-128-cbc") throws {
        guard privateKey.count == 32 else { return nil }
        try SECP256K1.verifyPrivateKey(privateKey: privateKey)
        try encryptDataToStorage(password, keyData: privateKey, aesMode: aesMode)
    }

    fileprivate func encryptDataToStorage(_ password: String, keyData: Data?, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1, aesMode: String = "aes-128-cbc") throws {
        if keyData == nil {
            throw AbstractKeystoreError.encryptionError("Encryption without key data")
        }
        let saltLen = 32
        let saltData = Data.random(length: saltLen)
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else { throw AbstractKeystoreError.keyDerivationError }
        let last16bytes = Data(derivedKey[(derivedKey.count - 16) ... (derivedKey.count - 1)])
        let encryptionKey = Data(derivedKey[0 ... 15])
        let IV = Data.random(length: 16)
        var aesCipher: AES!
        switch aesMode {
        case "aes-128-cbc":
            aesCipher = try? AES(key: encryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .noPadding)
        case "aes-128-ctr":
            aesCipher = try? AES(key: encryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .noPadding)
        default:
            aesCipher = nil
        }
        guard aesCipher != nil else { throw AbstractKeystoreError.aesError }
        let encryptedKey = try aesCipher.encrypt(keyData!.bytes)
        let encryptedKeyData = Data(bytes: encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: aesMode, cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)
        let pubKey = try Chain3Utils.privateToPublic(keyData!)
        let addr = try Chain3Utils.publicToAddress(pubKey)
        address = addr
        let keystoreparams = KeystoreParamsV3(address: addr.address.lowercased(), crypto: crypto, id: UUID().uuidString.lowercased(), version: 3)
        keystoreParams = keystoreparams
    }

    public func regenerate(oldPassword: String, newPassword: String, dkLen _: Int = 32, N _: Int = 4096, R _: Int = 6, P _: Int = 1) throws {
        var keyData = try getKeyData(oldPassword)
        if keyData == nil {
            throw AbstractKeystoreError.encryptionError("Failed to decrypt a keystore")
        }
        defer { Data.zero(&keyData!) }
        try encryptDataToStorage(newPassword, keyData: keyData!, aesMode: keystoreParams!.crypto.cipher)
    }

    fileprivate func getKeyData(_ password: String) throws -> Data? {
        guard let keystoreParams = self.keystoreParams else { return nil }
        guard let saltData = Data.fromHex(keystoreParams.crypto.kdfparams.salt) else { return nil }
        let derivedLen = keystoreParams.crypto.kdfparams.dklen
        var passwordDerivedKey: Data?
        switch keystoreParams.crypto.kdf {
        case "scrypt":
            guard let N = keystoreParams.crypto.kdfparams.n else { return nil }
            guard let P = keystoreParams.crypto.kdfparams.p else { return nil }
            guard let R = keystoreParams.crypto.kdfparams.r else { return nil }
            passwordDerivedKey = scrypt(password: password, salt: saltData, length: derivedLen, N: N, R: R, P: P)
        case "pbkdf2":
            guard let algo = keystoreParams.crypto.kdfparams.prf else { return nil }
            var hashVariant: HMAC.Variant?
            switch algo {
            case "hmac-sha256":
                hashVariant = HMAC.Variant.sha256
            case "hmac-sha384":
                hashVariant = HMAC.Variant.sha384
            case "hmac-sha512":
                hashVariant = HMAC.Variant.sha512
            default:
                hashVariant = nil
            }
            guard hashVariant != nil else { return nil }
            guard let c = keystoreParams.crypto.kdfparams.c else { return nil }
            guard let derivedArray = try? PKCS5.PBKDF2(password: Array(password.utf8), salt: saltData.bytes, iterations: c, keyLength: derivedLen, variant: hashVariant!).calculate() else { return nil }
            passwordDerivedKey = Data(bytes: derivedArray)
        default:
            return nil
        }
        guard let derivedKey = passwordDerivedKey else { return nil }
        var dataForMAC = Data()
        let derivedKeyLast16bytes = Data(derivedKey[(derivedKey.count - 16) ... (derivedKey.count - 1)])
        dataForMAC.append(derivedKeyLast16bytes)
        guard let cipherText = Data.fromHex(keystoreParams.crypto.ciphertext) else { return nil }
        if cipherText.count != 32 { return nil }
        dataForMAC.append(cipherText)
        let mac = dataForMAC.sha3(.keccak256)
        guard let calculatedMac = Data.fromHex(keystoreParams.crypto.mac), mac.constantTimeComparisonTo(calculatedMac) else { return nil }
        let cipher = keystoreParams.crypto.cipher
        let decryptionKey = derivedKey[0 ... 15]
        guard let IV = Data.fromHex(keystoreParams.crypto.cipherparams.iv) else { return nil }
        var decryptedPK: Array<UInt8>?
        switch cipher {
        case "aes-128-ctr":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .noPadding) else { return nil }
            decryptedPK = try aesCipher.decrypt(cipherText.bytes)
        case "aes-128-cbc":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .noPadding) else { return nil }
            decryptedPK = try? aesCipher.decrypt(cipherText.bytes)
        default:
            return nil
        }
        guard decryptedPK != nil else { return nil }
        return Data(bytes: decryptedPK!)
    }

    public func serialize() throws -> Data? {
        guard let params = self.keystoreParams else { return nil }
        let data = try JSONEncoder().encode(params)
        return data
    }
}
