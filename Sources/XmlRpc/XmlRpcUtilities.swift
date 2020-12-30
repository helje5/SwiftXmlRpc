//
//  XmlRpcUtilities.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public extension XmlRpc.Response {
  
  /**
   * Create a fault response from some arbitrary Swift.Error.
   *
   * Careful to not expose secret data, it is preferable to manually create
   * the fault!
   *
   * This sets the code to 500 and the reason to the `description` of the
   * Error.
   */
  @inlinable
  init(_ error: Swift.Error) {
    self = .fault(.init(code: 500, reason: "\(error)"))
  }
}

public extension XmlRpc.Value {

  /**
   * Access an XML-RPC value by index.
   *
   * For arrays it does the natural thing and return the array value if within
   * a valid range, otherwise `null`.
   *
   * For dictionaries this is an expensive (but convenient) operation. It
   * first sorts the keys, then it grabs the position.
   *
   * All other values return themselves if the index is 0, `null` otherwise.
   *
   * There is a corresponding `count` property which returns a matching count
   * (i.e. 0 for `null`, 1 for base types and the count for collections).
   */
  @inlinable
  subscript(index: Int) -> XmlRpc.Value {
    switch self {
      case .array(let values):
        guard index >= 0 && index < values.count else { return .null }
        return values[index]
        
      case .dictionary(let dict):
        guard index >= 0 && index < dict.count else { return .null }
        return dict[dict.keys.sorted()[index]] ?? .null // EXPENSIVE!
    
      case .string, .null, .bool, .data, .int, .double, .dateTime:
        guard index == 0 else { return .null }
        return self
    }
  }

  /**
   * Returns 0 for `null`, 1 for base types and the actual count for
   * arrays and dictionaries.
   */
  @inlinable
  var count : Int {
    switch self {
      case .null: return 0
      case .string, .bool, .int, .double, .dateTime, .data: return 1
      case .array     (let elements) : return elements.count
      case .dictionary(let values)   : return values  .count
    }
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
}

public extension XmlRpc.Value {
  
  @inlinable
  var stringValue : String {
    switch self {
      case .null               : return "<null>"
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
  var intValue : Int? {
    switch self {
      case .null               : return nil
      case .string  (let s)    : return Int(s)
      case .bool    (let flag) : return flag ? 1 : 0
      case .int     (let v)    : return v
      case .double  (let v)    : return Int(v)
      case .dateTime           : return nil // FIXME: parse & use utime?
      case .data               : return nil
      case .array, .dictionary : return nil
    }
  }
  
  @inlinable
  var doubleValue : Double? {
    switch self {
      case .null               : return 0.0
      case .string  (let s)    : return Double(s)
      case .bool    (let flag) : return flag ? 1 : 0
      case .int     (let v)    : return Double(v)
      case .double  (let v)    : return v
      case .dateTime           : return nil // FIXME: parse & use utime?
      case .data               : return nil
      case .array, .dictionary : return nil
    }
  }
}


import struct Foundation.URL

extension XmlRpc.Value {
  
  @inlinable
  public init(_ url: URL) { self.init(url.absoluteString) }
}
