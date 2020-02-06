//
//  BIP32HDwallet.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 09.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import CryptoSwift
import Foundation

extension UInt32 {
    public func serialize32() -> Data {
        let uint32 = UInt32(self)
        var bigEndian = uint32.bigEndian
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        let byteArray = Array(bytePtr)
        return Data(byteArray)
    }
}

private extension Array where Element == UInt8 {
    func checkEntropySize() throws {
        guard count == 64 else { throw HDNode.Error.invalidEntropySize }
    }
}

private extension Data {
    func checkPublicKeyPrefix() throws {
        let prefix = self[0]
        guard prefix == 0x02 || prefix == 0x03 else { throw HDNode.Error.invalidPublicKeyPrefix }
    }
}

public class HDNode {
    public struct HDversion {
        public var privatePrefix = Data.fromHex("0x0488ADE4")!
        public var publicPrefix = Data.fromHex("0x0488B21E")!
        public init() {}
    }

    public var path: String? = "m"
    public var privateKey: Data?
    public var publicKey: Data
    public var chaincode: Data
    public var depth: UInt8
    public var parentFingerprint: Data = Data(repeating: 0, count: 4)
    public var childNumber: UInt32 = UInt32(0)
    public var isHardened: Bool {
        return childNumber >= (UInt32(1) << 31)
    }

    public var index: UInt32 {
        if isHardened {
            return childNumber - (UInt32(1) << 31)
        } else {
            return childNumber
        }
    }

    public var hasPrivate: Bool {
        return privateKey != nil
    }

    init() {
        publicKey = Data()
        chaincode = Data()
        depth = UInt8(0)
    }

    public convenience init?(_ serializedString: String) {
        let data = Data(Base58.bytesFromBase58(serializedString))
        self.init(data)
    }

    public init?(_ data: Data) {
        guard data.count == 82 else { return nil }
        let header = data[0 ..< 4]
        var serializePrivate = false
        if header == HDNode.HDversion().privatePrefix {
            serializePrivate = true
        }
        depth = data[4 ..< 5].bytes[0]
        parentFingerprint = data[5 ..< 9]
        let cNum = data[9 ..< 13].bytes
        childNumber = UnsafePointer(cNum).withMemoryRebound(to: UInt32.self, capacity: 1) {
            $0.pointee
        }
        chaincode = data[13 ..< 45]
        if serializePrivate {
            privateKey = data[46 ..< 78]
            guard let pubKey = try? Chain3Utils.privateToPublic(privateKey!, compressed: true) else { return nil }
            guard pubKey[0] == 0x02 || pubKey[0] == 0x03 else { return nil }
            publicKey = pubKey
        } else {
            publicKey = data[45 ..< 78]
        }
        let hashedData = data[0 ..< 78].sha256().sha256()
        let checksum = hashedData[0 ..< 4]
        if checksum != data[78 ..< 82] { return nil }
    }

    public enum Error: Swift.Error {
        case invalidSeedSize // seed.count should be at least 16 bytes
        case invalidEntropySize
        case invalidPublicKeyPrefix
    }

    public init(seed: Data) throws {
        guard seed.count >= 16 else { throw Error.invalidSeedSize }
        let hmacKey = "Bitcoin seed".data(using: .ascii)!
        let hmac: Authenticator = HMAC(key: hmacKey.bytes, variant: HMAC.Variant.sha512)
        let entropy = try hmac.authenticate(seed.bytes)
        try entropy.checkEntropySize()
        let I_L = entropy[0 ..< 32]
        let I_R = entropy[32 ..< 64]
        chaincode = Data(I_R)
        let privKeyCandidate = Data(I_L)
        try SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate)
        let pubKeyCandidate = try SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true)
        guard pubKeyCandidate[0] == 0x02 || pubKeyCandidate[0] == 0x03 else { throw Error.invalidPublicKeyPrefix }
        publicKey = pubKeyCandidate
        privateKey = privKeyCandidate
        depth = 0x00
        childNumber = UInt32(0)
    }

    private static var curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
    public static var defaultPath: String = "m/44'/60'/0'/0"
    public static var defaultPathPrefix: String = "m/44'/60'/0'"
    public static var defaultPathMetamask: String = "m/44'/60'/0'/0/0"
    public static var defaultPathMetamaskPrefix: String = "m/44'/60'/0'/0"
    public static var hardenedIndexPrefix: UInt32 = (UInt32(1) << 31)
}

extension HDNode {
    public enum DeriveError: Swift.Error {
        case providePrivateKey
        case indexIsTooBig
        case depthIsTooBig
        case noHardenedDerivation // no derivation of hardened public key from extended public key
        case pathComponentsShouldBeConvertableToNumber
    }

    public func derive(index: UInt32, derivePrivateKey: Bool, hardened: Bool = false) throws -> HDNode {
        if derivePrivateKey {
            guard hasPrivate else { throw DeriveError.providePrivateKey }
            let entropy: Array<UInt8>
            var trueIndex: UInt32
            if index >= (UInt32(1) << 31) || hardened {
                trueIndex = index
                if trueIndex < (UInt32(1) << 31) {
                    trueIndex = trueIndex + (UInt32(1) << 31)
                }
                let hmac: Authenticator = HMAC(key: chaincode.bytes, variant: .sha512)
                var inputForHMAC = Data()
                inputForHMAC.append(Data([UInt8(0x00)]))
                inputForHMAC.append(privateKey!)
                inputForHMAC.append(trueIndex.serialize32())
                entropy = try hmac.authenticate(inputForHMAC.bytes)
                try entropy.checkEntropySize()
            } else {
                trueIndex = index
                let hmac: Authenticator = HMAC(key: chaincode.bytes, variant: .sha512)
                var inputForHMAC = Data()
                inputForHMAC.append(publicKey)
                inputForHMAC.append(trueIndex.serialize32())
                entropy = try hmac.authenticate(inputForHMAC.bytes)
                try entropy.checkEntropySize()
            }
            let I_L = entropy[0 ..< 32]
            let I_R = entropy[32 ..< 64]
            let cc = Data(I_R)
            let bn = BigUInt(Data(I_L))
            if bn > HDNode.curveOrder {
                guard trueIndex != UInt32.max else { throw DeriveError.indexIsTooBig }
                return try derive(index: index + 1, derivePrivateKey: derivePrivateKey, hardened: hardened)
            }
            let newPK = (bn + BigUInt(privateKey!)) % HDNode.curveOrder
            if newPK == BigUInt(0) {
                guard trueIndex != UInt32.max else { throw DeriveError.indexIsTooBig }
                return try derive(index: index + 1, derivePrivateKey: derivePrivateKey, hardened: hardened)
            }
            let privKeyCandidate = newPK.serialize().setLengthLeft(32)!
            try SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate)
            let pubKeyCandidate = try SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true)
            try pubKeyCandidate.checkPublicKeyPrefix()
            guard depth < UInt8.max else { throw DeriveError.depthIsTooBig }
            let newNode = HDNode()
            newNode.chaincode = cc
            newNode.depth = depth + 1
            newNode.publicKey = pubKeyCandidate
            newNode.privateKey = privKeyCandidate
            newNode.childNumber = trueIndex
            let fprint = RIPEMD160.hash(message: publicKey.sha256())[0 ..< 4]
            newNode.parentFingerprint = fprint
            var newPath = String()
            if newNode.isHardened {
                newPath = path! + "/"
                newPath += String(newNode.index % HDNode.hardenedIndexPrefix) + "'"
            } else {
                newPath = path! + "/" + String(newNode.index)
            }
            newNode.path = newPath
            return newNode
        } else { // deriving only the public key
            guard !(index >= (UInt32(1) << 31) || hardened) else { throw DeriveError.noHardenedDerivation }
            let hmac: Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
            var inputForHMAC = Data()
            inputForHMAC.append(publicKey)
            inputForHMAC.append(index.serialize32())
            var entropy = try hmac.authenticate(inputForHMAC.bytes) // derive public key when is itself public key
            try entropy.checkEntropySize()
            let tempKey = Data(entropy[0 ..< 32])
            let chaincode = Data(entropy[32 ..< 64])
            let bn = BigUInt(tempKey)
            if bn > HDNode.curveOrder {
                guard index < UInt32.max else { throw DeriveError.indexIsTooBig }
                return try derive(index: index + 1, derivePrivateKey: derivePrivateKey, hardened: hardened)
            }
            try SECP256K1.verifyPrivateKey(privateKey: tempKey)
            let pubKeyCandidate = try SECP256K1.privateToPublic(privateKey: tempKey, compressed: true)
            try pubKeyCandidate.checkPublicKeyPrefix()
            let newPublicKey = try SECP256K1.combineSerializedPublicKeys(keys: [self.publicKey, pubKeyCandidate], outputCompressed: true)
            try newPublicKey.checkPublicKeyPrefix()
            guard depth < UInt8.max else { throw DeriveError.depthIsTooBig }
            let newNode = HDNode()
            newNode.chaincode = chaincode
            newNode.depth = depth + 1
            newNode.publicKey = pubKeyCandidate
            newNode.childNumber = index
            let fprint = RIPEMD160.hash(message: publicKey.sha256())[0 ..< 4]
            newNode.parentFingerprint = fprint
            var newPath = String()
            if newNode.isHardened {
                newPath = path! + "/"
                newPath += String(newNode.index % HDNode.hardenedIndexPrefix) + "'"
            } else {
                newPath = path! + "/" + String(newNode.index)
            }
            newNode.path = newPath
            return newNode
        }
    }

    public func derive(path: String, derivePrivateKey: Bool = true) throws -> HDNode {
        let components = path.components(separatedBy: "/")
        var currentNode: HDNode = self
        var firstComponent = 0
        if path.hasPrefix("m") {
            firstComponent = 1
        }
        for component in components[firstComponent ..< components.count] {
            var component = component
            let hardened = component.hasSuffix("'")
            if hardened {
                component.removeLast()
            }
            guard let index = UInt32(component) else { throw DeriveError.pathComponentsShouldBeConvertableToNumber }
            currentNode = try currentNode.derive(index: index, derivePrivateKey: derivePrivateKey, hardened: hardened)
        }
        return currentNode
    }

    public func serializeToString(serializePublic: Bool = true, version: HDversion = HDversion()) -> String? {
        guard let data = self.serialize(serializePublic: serializePublic, version: version) else { return nil }
        let encoded = Base58.base58FromBytes(data.bytes)
        return encoded
    }

    public func serialize(serializePublic: Bool = true, version: HDversion = HDversion()) -> Data? {
        var data = Data()
        if !serializePublic && !hasPrivate { return nil }
        if serializePublic {
            data.append(version.publicPrefix)
        } else {
            data.append(version.privatePrefix)
        }
        data.append(contentsOf: [self.depth])
        data.append(parentFingerprint)
        data.append(childNumber.serialize32())
        data.append(chaincode)
        if serializePublic {
            data.append(publicKey)
        } else {
            data.append(contentsOf: [0x00])
            data.append(privateKey!)
        }
        let hashedData = data.sha256().sha256()
        let checksum = hashedData[0 ..< 4]
        data.append(checksum)
        return data
    }
}
