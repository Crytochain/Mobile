//
//  C3Contract.swift
//  chain3swift
//
//  Created by Dmitry on 10/11/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

extension ContractV2.EventFilter {
    public var objc: C3ContractEventFilter {
        return C3ContractEventFilter(self)
    }
}
@objc public class C3ContractEventFilter: NSObject, SwiftContainer {
    public var swift: ContractV2.EventFilter
    public required init(_ swift: ContractV2.EventFilter) {
        self.swift = swift
    }
    
    @objc public var parameterName: String {
        get { return swift.parameterName }
        set { swift.parameterName = newValue }
    }
    @objc public var parameterValues: [AnyObject] {
        get { return swift.parameterValues }
        set { swift.parameterValues = newValue }
    }
}
@objc public class C3ContractParsedEvent: NSObject {
    @objc public let eventName: String?
    @objc public let eventData: [String: Any]?
    init(eventName: String?, eventData: [String: Any]?) {
        self.eventName = eventName
        self.eventData = eventData
    }
}

extension ContractProtocol {
    public var objc: C3Contract {
        return C3Contract(self as! ContractV2)
    }
}

@objc public class C3Contract: NSObject, C3OptionsInheritable, SwiftContainer {
    public var swift: ContractV2
    var _swiftOptions: Chain3Options {
        get { return swift.options }
        set { swift.options = newValue }
    }
    public required init(_ swift: ContractV2) {
        self.swift = swift
        super.init()
        options = C3Options(object: self)
    }
    
    @objc public var allEvents: [String] {
        return swift.allEvents
    }
    
    @objc public var allMethods: [String] {
        return swift.allMethods
    }
    
    @objc public var address: C3Address? {
        get { return swift.address?.objc }
        set { swift.address = newValue?.swift }
    }
    
    @objc public var options: C3Options!
    
    @objc public init(_ abiString: String, at address: C3Address? = nil) throws {
        swift = try ContractV2(abiString, at: address?.swift)
    }
    
    @objc public func deploy(bytecode: Data, parameters: [Any], extraData: Data?, options: C3Options?) throws -> C3LBRTransaction {
        let extraData = extraData ?? Data()
        return try swift.deploy(bytecode: bytecode, parameters: parameters, extraData: extraData, options: options?.swift).objc
    }
    
    @objc public func method(_ method: String, parameters: [Any], extraData: Data?, options: C3Options?) throws -> C3LBRTransaction {
        let extraData = extraData ?? Data()
        return try swift.method(method, parameters: parameters, extraData: extraData, options: options?.swift).objc
    }
    
    @objc public func parseEvent(_ eventLog: C3EventLog) -> C3ContractParsedEvent {
        let (name,data) = swift.parseEvent(eventLog.swift)
        return C3ContractParsedEvent(eventName: name, eventData: data)
    }
    
    @objc public func testBloomForEventPrecence(eventName: String, bloom: C3LBRBloomFilter) -> Bool {
        return swift.testBloomForEventPrecence(eventName: eventName, bloom: bloom.swift) ?? false
    }
    
    @objc public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
        return swift.decodeReturnData(method, data: data)
    }
    
    @objc public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
        return swift.decodeInputData(method, data: data)
    }
    
    @objc public func decodeInputData(_ data: Data) -> [String: Any]? {
        return swift.decodeInputData(data)
    }
}

