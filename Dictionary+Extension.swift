//
//  Dictionary+Extension.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 15.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value: Equatable {
    func keyForValue(value: Value) -> String? {
        for key in keys {
            if self[key] == value {
                return key
            }
        }
        return nil
    }
}
