//
//  DebugOverridable.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/12/21.
//

import Foundation

@propertyWrapper
struct DebugOverridable<Value> {
    #if DEBUG
    var wrappedValue: Value
    #else
    let wrappedValue: Value
    #endif
}
