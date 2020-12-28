//
//  XmlRpcUtilities.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension XmlRpc.Value {

  /**
   * Access an XML-RPC value by index.
   *
   * For arrays it does the natural thing and return the array value if within
   * a valid range, otherwise `null`.
   *
   * For dictionaries this always returns `null`.
   *
   * All other values return themselves if the index is 0, `null` otherwise.
   */
  @inlinable
  subscript(index: Int) -> XmlRpc.Value {
    guard case .array(let values) = self else {
      guard index == 0      else { return .null }
      if case .dictionary = self { return .null }
      return self
    }
    return index >= 0 && index < values.count ? values[index] : .null
  }
  
  /**
   * Access an XML-RPC dictionary value by string key.
   *
   * This returns `null` for all other kinds of values.
   */
  @inlinable
  subscript(key: String) -> XmlRpc.Value {
    guard case .dictionary(let values) = self else { return .null }
    return values[key] ?? .null
  }

  @inlinable
  var stringValue : String {
    switch self {
      case .null               : return  "<null>"
      case .string  (let s)    : return s
      case .bool    (let flag) : return flag ? "YES" : "NO"
      case .int     (let v)    : return "\(v)"
      case .double  (let v)    : return "\(v)"
      case .dateTime(let v)    : return "\(v)"
      case .data    (let v)    : return v.base64EncodedString()
      case .array, .dictionary : return description
    }
  }
  
  @inlinable
  var count : Int {
    switch self {
      case .null: return 0
      case .string, .bool, .int, .double, .dateTime, .data: return 1
      case .array     (let elements) : return elements.count
      case .dictionary(let values)   : return values  .count
    }
  }
}


import struct Foundation.URL

extension XmlRpc.Value {
  
  @inlinable
  public init(_ url: URL) { self.init(url.absoluteString) }
}
