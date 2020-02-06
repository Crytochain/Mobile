//
//  C3Provider.swift
//  chain3swift
//
//  Created by Dmitry on 11/9/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

extension Chain3HttpProvider {
    public var objc: C3Chain3HttpProvider {
		return C3Chain3HttpProvider(self)
	}
}
@objc public class C3Chain3HttpProvider: NSObject, SwiftContainer {
	public let swift: Chain3HttpProvider
	public required init(_ swift: Chain3HttpProvider) {
		self.swift = swift
	}
	
	@objc public var url: URL {
		get { return swift.url }
		set { swift.url = newValue }
	}
	
	@objc public var network: C3NetworkId? {
		get { return swift.network?.objc }
		set { swift.network = newValue?.swift }
	}
	
	@objc public var attachedKeystoreManager: C3KeystoreManager? {
		get { return swift.attachedKeystoreManager?.objc }
		set { swift.attachedKeystoreManager = newValue?.swift }
	}
	
	@objc public var session: URLSession {
		get { return swift.session }
		set { swift.session = newValue }
	}
	
	@objc public init?(_ httpProviderURL: URL, network net: C3NetworkId? = nil, keystoreManager manager: C3KeystoreManager? = nil) {
		guard let swift = Chain3HttpProvider(httpProviderURL, network: net?.swift, keystoreManager: manager?.swift) else { return nil }
		self.swift = swift
	}
}


//@objc public class C3GatewayProvider: C3Chain3HttpProvider {
//    @objc public init?(_ net: C3NetworkId, accessToken token: String? = nil, keystoreManager manager: C3KeystoreManager? = nil) {
//        guard let swift = GatewayProvider(net.swift, accessToken: token, keystoreManager: manager?.swift) else { return nil }
//        super.init(swift)
//    }
//
//    public required init(_ swift: Chain3HttpProvider) {
//        super.init(swift)
//    }
//}
