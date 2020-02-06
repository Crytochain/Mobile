//
//  AbstractKeystore.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 10.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

public protocol AbstractKeystore {
    var addresses: [Address] { get }
    var isHDKeystore: Bool { get }
    func UNSAFE_getPrivateKeyData(password: String, account: Address) throws -> Data
}

public enum AbstractKeystoreError: Error {
    case noEntropyError
    case keyDerivationError
    case aesError
    case invalidAccountError
    case invalidPasswordError
    case encryptionError(String)
}
