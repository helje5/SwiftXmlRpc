//
//  XmlRpcMultiCall.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

// MARK: - Parsing MultiCall's

public extension XmlRpc.Call {
  
  @inlinable
  init?(xmlRpcValue: XmlRpc.Value) {
    // Note: tolerant in consumption
    guard case .dictionary(let dict) = xmlRpcValue else {
      print("ERROR: invalid Call, not a dict:", xmlRpcValue)
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

  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    guard case .dictionary(let dict) = xmlRpcValue else { return nil }
    guard case .some(.int(let code)) = dict["faultCode"]  else { return nil }
    self.init(code: code, reason: dict["reason"]?.stringValue ?? "")
  }
  
  /* Render a fault as an XML-RPC Value */
  @inlinable
  public var xmlRpcValue : XmlRpc.Value {
    return .dictionary([ "faultCode": .int(code), "reason": .string(reason) ])
  }
}

extension XmlRpc.Response: XmlRpcValueRepresentable {

  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    switch xmlRpcValue {
      case .dictionary:
        guard let fault = XmlRpc.Fault(xmlRpcValue: xmlRpcValue) else {
          return nil
        }
        self = .fault(fault)
        
      case .array(let list):
        if list.count == 1 {
          self = .value(list[0])
        }
        else {
          assertionFailure("expected single item array in multicall response")
          self = .value(xmlRpcValue)
        }
        
      default:
        assertionFailure("expected fault-dict or array in multicall response")
        self = .value(xmlRpcValue)
    }
  }
  
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
