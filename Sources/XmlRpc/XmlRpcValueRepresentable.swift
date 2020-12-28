//
//  XmlRpcValueRepresentable.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public protocol XmlRpcValueRepresentable {
  var xmlRpcValue : XmlRpc.Value { get }
}

extension XmlRpc.Value: XmlRpcValueRepresentable {
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return self }
}

extension String: XmlRpcValueRepresentable {
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .string(self) }
}

extension Int: XmlRpcValueRepresentable {
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .int(self) }
}

extension Double: XmlRpcValueRepresentable {
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .double(self) }
}

public extension Collection where Element : XmlRpcValueRepresentable {
  
  /**
   * Encoding XML-RPC responses themselves in XML-RPC using the
   * `system.multicall` convention, which says:
   * - render faults as their dictionaries
   * - render values within a single-item array
   */
  @inlinable
  var xmlRpcValue : XmlRpc.Value {
    .array(map { $0.xmlRpcValue })
  }
}
