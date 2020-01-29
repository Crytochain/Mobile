//
//  Chain3+Provider.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation

/**
 Custom Chain3 HTTP provider of Gateway nodes.
 chain3swift uses Gateway mainnet as default provider
 */
public final class GatewayProvider: Chain3HttpProvider {
    /**
     - parameter net: defines network id. applies to address "https://\(net).gateway.io/"
     - parameter token: your gateway token. appends to url address
     - parameter manager: KeystoreManager for this provider
     */
    public init?(_ net: NetworkId, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) {
        var requestURLstring = "https://\(net).gateway.io/"
        if token != nil {
            requestURLstring = requestURLstring + token!
        }
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net, keystoreManager: manager)
    }
}
