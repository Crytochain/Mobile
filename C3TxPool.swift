//
//  C3TxPool.swift
//  chain3swift
//
//  Created by Dmitry on 11/9/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

@objc public class C3TxPool: NSObject {
	@objc public unowned var chain3: C3Chain3
	@objc public init(chain3: C3Chain3) {
		self.chain3 = chain3
	}
	@objc public func status(completion: @escaping (C3TxPoolStatus?,Error?)->()) {
		chain3.swift.txpool.status().done {
			completion($0.objc, nil)
		}.catch {
			completion(nil, $0)
		}
	}
	@objc public func inspect(completion: @escaping (C3TxPoolInspect?,Error?)->()) {
		chain3.swift.txpool.inspect().done {
			completion($0.objc, nil)
		}.catch {
			completion(nil, $0)
		}
	}
	@objc public func content(completion: @escaping (C3TxPoolContent?,Error?)->()) {
		chain3.swift.txpool.content().done {
			completion($0.objc, nil)
		}.catch {
			completion(nil, $0)
		}
	}
}

extension TxPoolStatus {
    public var objc: C3TxPoolStatus {
		return C3TxPoolStatus(self)
	}
}
@objc public class C3TxPoolStatus: NSObject, SwiftContainer {
	public let swift: TxPoolStatus
	public required init(_ swift: TxPoolStatus) {
		self.swift = swift
	}
	@objc public var pending: Int { return swift.pending }
	@objc public var queued: Int { return swift.queued }
}

extension TxPoolInspect {
    public var objc: C3TxPoolInspect {
		return C3TxPoolInspect(self)
	}
}
@objc public class C3TxPoolInspect: NSObject, SwiftContainer {
	public let swift: TxPoolInspect
	public required init(_ swift: TxPoolInspect) {
		self.swift = swift
	}
	@objc public var pending: [C3InspectedTransaction] { return swift.pending.map { $0.objc } }
	@objc public var queued: [C3InspectedTransaction] { return swift.queued.map { $0.objc } }
	
}

extension InspectedTransaction {
    public var objc: C3InspectedTransaction {
		return C3InspectedTransaction(self)
	}
}
@objc public class C3InspectedTransaction: NSObject, SwiftContainer {
	public let swift: InspectedTransaction
	public required init(_ swift: InspectedTransaction) {
		self.swift = swift
	}
	@objc public var from: C3Address { return swift.from.objc }
	@objc public var nonce: Int { return swift.nonce }
	@objc public var to: C3Address { return swift.to.objc }
	@objc public var value: C3UInt { return swift.value.objc }
	@objc public var gasLimit: C3UInt { return swift.gasLimit.objc }
	@objc public var gasPrice: C3UInt { return swift.gasPrice.objc }
	
}

extension TxPoolContent {
    public var objc: C3TxPoolContent {
		return C3TxPoolContent(self)
	}
}
@objc public class C3TxPoolContent: NSObject, SwiftContainer {
	public let swift: TxPoolContent
	public required init(_ swift: TxPoolContent) {
		self.swift = swift
	}
	@objc public var pending: [C3TxPoolTransaction] { return swift.pending.map { $0.objc } }
	@objc public var queued: [C3TxPoolTransaction] { return swift.queued.map { $0.objc } }
	
}

extension TxPoolTransaction {
    public var objc: C3TxPoolTransaction {
		return C3TxPoolTransaction(self)
	}
}
@objc public class C3TxPoolTransaction: NSObject, SwiftContainer {
	public let swift: TxPoolTransaction
	public required init(_ swift: TxPoolTransaction) {
		self.swift = swift
	}
	@objc public var from: C3Address { return swift.from.objc }
	@objc public var nonce: Int { return swift.nonce }
	@objc public var to: C3Address { return swift.to.objc }
	@objc public var value: C3UInt { return swift.value.objc }
	@objc public var gasLimit: C3UInt { return swift.gasLimit.objc }
	@objc public var gasPrice: C3UInt { return swift.gasPrice.objc }
	@objc public var input: Data { return swift.input }
	@objc public var transactionHash: Data { return swift.hash }
	@objc public var v: C3UInt { return swift.v.objc }
	@objc public var r: C3UInt { return swift.r.objc }
	@objc public var s: C3UInt { return swift.s.objc }
	@objc public var blockHash: Data { return swift.blockHash }
	@objc public var transactionIndex: C3UInt { return swift.transactionIndex.objc }
	
}


