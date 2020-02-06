//
//  Bridging.swift
//  chain3swift
//
//  Created by Dmitry on 09/11/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

public protocol SwiftBridgeable {
    associatedtype SwiftType
    var swift: SwiftType { get }
}
public protocol SwiftContainer: SwiftBridgeable {
    init(_ swift: SwiftType)
}

//public extension _ObjectiveCBridgeable where _ObjectiveCType: SwiftBridgeable, _ObjectiveCType.SwiftType == Self {
//    static func _forceBridgeFromObjectiveC(_ source: _ObjectiveCType, result: inout Self?) {
//        result = source.swift
//    }
//
//    static func _conditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType, result: inout Self?) -> Bool {
//        result = source.swift
//        return true
//    }
//
//    static func _unconditionallyBridgeFromObjectiveC(_ source: _ObjectiveCType?) -> Self {
//        return source!.swift
//    }
//}

//extension _ObjectiveCBridgeable {
//    var objc: _ObjectiveCType {
//        return _bridgeToObjectiveC()
//    }
//}
