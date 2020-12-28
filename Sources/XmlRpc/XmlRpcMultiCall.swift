//
//  XmlRpcMultiCall.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

// MARK: - Parsing MultiCall's

public extension XmlRpc.Call {
  
  @inlinable
  init?(multiCall: XmlRpc.Value) {
    // Note: tolerant in consumption
    guard case .dictionary(let dict) = multiCall else {
      print("ERROR: invalid Call, not a dict:", multiCall)
      return nil
    }
    guard let methodName = dict["methodName"]?.stringValue else {
      print("ERROR: invalid Call, no method:", dict)
      return nil
    }

    let parameters : [ XmlRpc.Value ]

    if let paramValues = dict["params"] {
      switch paramValues {
        case .array(let values) : parameters = values
        case .null              : parameters = []
        case .string, .bool, .int, .double, .dateTime, .data, .dictionary:
          parameters = [ paramValues ]
      }
    }
    else {
      parameters = []
    }
    
    self.methodName = methodName
    self.parameters = parameters
  }
}


// MARK: - Generating MultiCall's

extension XmlRpc.Call: XmlRpcValueRepresentable {
  
  /**
   * Encoding XML-RPC calls themselves in XML-RPC using the
   * `system.multicall` convention (struct w/ 'methodName' and 'parameters').
   */
  @inlinable
  public var xmlRpcValue : XmlRpc.Value {
    return .dictionary([ "methodName" : .string(methodName),
                         "params"     : .array(parameters) ])
  }
}

extension XmlRpc.Fault: XmlRpcValueRepresentable {
  
  /* Render a fault as an XML-RPC Value */
  @inlinable
  public var xmlRpcValue : XmlRpc.Value {
    return .dictionary([ "faultCode": .int(code), "reason": .string(reason) ])
  }
}

extension XmlRpc.Response: XmlRpcValueRepresentable {

  /**
   * Encoding XML-RPC responses themselves in XML-RPC using the
   * `system.multicall` convention, which says:
   * - render faults as their dictionaries
   * - render values within a single-item array
   */
  @inlinable
  public var xmlRpcValue : XmlRpc.Value {
    switch self {
      case .fault(let fault): return fault.xmlRpcValue
      case .value(let value): return .array([ value ])
    }
  }
}
