//
//  Chain3+Instance.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

/// A chain3 instance bound to provider. All further functionality is provided under mc.*. namespaces.
public class Chain3: Chain3OptionsInheritable {
    public static var `default`: Chain3 = Chain3(gateway: .mainnet)
    public var provider: Chain3Provider
    public var options: Chain3Options = .default
    public var defaultBlock = "latest"
    public var requestDispatcher: JsonRpcRequestDispatcher
    
    public var keystoreManager: KeystoreManager? {
        get { return provider.attachedKeystoreManager }
        set { provider.attachedKeystoreManager = newValue }
    }
    
    public var txpool: TxPool {
        return TxPool(chain3: self)
    }
    /// Public chain3.mc.* namespace.
    public lazy var mc = Chain3MC(provider: self.provider, chain3: self)
    
    /// Public chain3.personal.* namespace.
    public lazy var personal = Chain3Personal(provider: self.provider, chain3: self)
    
    /// Public chain3.wallet.* namespace.
    public lazy var wallet = Chain3Wallet(provider: self.provider, chain3: self)
    
    /// Public chain3.vnode.* namespace.
    public lazy var vnode = Chain3Vnode(provider: self.provider, chain3: self)
    
    /// Public chain3.scs.* namespace.
    public lazy var scs = Chain3SCS(provider: self.provider, chain3: self)
    
    /// Public chain3.browserFunctions.* namespace.
    public lazy var browserFunctions = Chain3BrowserFunctions(provider: self.provider, chain3: self)

    /// Add a provider request to the dispatch queue.
    public func dispatch(_ request: JsonRpcRequest) -> Promise<JsonRpcResponse> {
        return requestDispatcher.addToQueue(request: request)
    }

    /// Raw initializer using a Chain3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Chain3Provider, queue _: OperationQueue? = nil, requestDispatcher: JsonRpcRequestDispatcher? = nil) {
        provider = prov
        if requestDispatcher == nil {
            self.requestDispatcher = JsonRpcRequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .Batch(32))
        } else {
            self.requestDispatcher = requestDispatcher!
        }
    }

    /**
     Keystore manager can be bound to Chain3 instance.
     If some manager is bound all further account related functions, such
     as account listing, transaction signing, etc.
     are done locally using private keys and accounts found in a manager.
     */
    public func addKeystoreManager(_ manager: KeystoreManager?) {
        provider.attachedKeystoreManager = manager
    }
}
