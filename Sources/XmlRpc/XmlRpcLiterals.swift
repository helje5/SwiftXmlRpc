//
//  XmlRpcLiterals.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

extension XmlRpc.Value : ExpressibleByStringLiteral {
  
  @inlinable
  public init(_ s: String) { self = .string(s) }
  
  @inlinable
  public init(stringLiteral value: String) { self = .string(value) }
}

extension XmlRpc.Value : ExpressibleByNilLiteral {
  
  @inlinable
  public init() { self = .null }

  @inlinable
  public init(nilLiteral: ()) { self = .null }
}

extension XmlRpc.Value : ExpressibleByIntegerLiteral {
  
  @inlinable
  public init(_ value: Int) { self = .int(value) }
  
  @inlinable
  public init(integerLiteral value: Int) { self = .int(value) }
}

extension XmlRpc.Value : ExpressibleByFloatLiteral {

  @inlinable
  public init(_ value: Double) { self = .double(value) }

  @inlinable
  public init(floatLiteral value: Double) { self = .double(value) }
}

extension XmlRpc.Value : ExpressibleByBooleanLiteral {
  
  @inlinable
  public init(booleanLiteral value: Bool) { self = .bool(value) }
}

extension XmlRpc.Value : ExpressibleByArrayLiteral {
  
  @inlinable
  public init(arrayLiteral elements: XmlRpc.Value...) { 
    self = .array(elements)
  }
}

extension XmlRpc.Value : ExpressibleByDictionaryLiteral {
  
  @inlinable
  public init(dictionaryLiteral elements: ( String , XmlRpc.Value )...) {
    var dict = [ String : XmlRpc.Value ]()
    dict.reserveCapacity(elements.count)
    for ( key, value ) in elements { dict[key] = value }
    self = .dictionary(dict)
  }
}
