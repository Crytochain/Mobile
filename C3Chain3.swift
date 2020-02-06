//
//  C3Chain3.swift
//  chain3swift
//
//  Created by Dmitry on 11/9/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

extension Chain3Provider {
    public var objc: C3Chain3HttpProvider {
		guard let provider = self as? Chain3HttpProvider else { fatalError("\(self) is not convertable to objective-c C3Chain3HttpProvider") }
		return provider.objc
	}
}

extension Chain3 {
    public var objc: C3Chain3 {
		return C3Chain3(self)
	}
}

@objc public class C3Chain3: NSObject, C3OptionsInheritable, SwiftContainer {
	public var swift: Chain3
    var _swiftOptions: Chain3Options {
        get { return swift.options }
        set { swift.options = newValue }
    }
	public required init(_ swift: Chain3) {
		self.swift = swift
		super.init()
		options = C3Options(object: self)
	}
	
	@objc public static var `default`: C3Chain3 {
		get { return Chain3.default.objc }
		set { Chain3.default = newValue.swift }
	}
	@objc public var provider: C3Chain3HttpProvider {
		get { return swift.provider.objc }
		set { swift.provider = newValue.swift }
	}
	@objc public var options: C3Options!
	@objc public var defaultBlock: String {
		get { return swift.defaultBlock }
		set { swift.defaultBlock = newValue }
	}
	@objc public var requestDispatcher: C3JsonRpcRequestDispatcher {
		get { return swift.requestDispatcher.objc }
		set { swift.requestDispatcher = newValue.swift }
	}
	@objc public var keystoreManager: C3KeystoreManager? {
		get { return swift.provider.attachedKeystoreManager?.objc }
		set { swift.provider.attachedKeystoreManager = newValue?.swift }
	}
	@objc public var txpool: C3TxPool {
		return C3TxPool(chain3: self)
	}
	
	@objc public func dispatch(_ request: C3JsonRpcRequest, completion: @escaping (C3JsonRpcResponse?,Error?)->()) {
		swift.dispatch(request.swift).done {
			completion($0.objc,nil)
		}.catch {
			completion(nil,$0)
		}
	}
	
	@objc public init(provider prov: C3Chain3HttpProvider, queue: OperationQueue? = nil) {
		swift = Chain3(provider: prov.swift, queue: queue)
		super.init()
		options = C3Options(object: self)
	}
	
    @objc public lazy var mc = C3MC(chain3: self)
    @objc public lazy var personal = C3Personal(chain3: self)
    @objc public lazy var wallet = C3Wallet(chain3: self)
	
	@objc public init(gateway networkId: C3NetworkId) {
		swift = Chain3(gateway: networkId.swift)
		super.init()
		options = C3Options(object: self)
	}
	
	@objc public init(gateway networkId: C3NetworkId, accessToken: String) {
		swift = Chain3(gateway: networkId.swift, accessToken: accessToken)
		super.init()
		options = C3Options(object: self)
	}
	
	@objc public init?(url: URL) {
		guard let swift = Chain3(url: url) else { return nil }
		self.swift = swift
		super.init()
		options = C3Options(object: self)
	}
}
