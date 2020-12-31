//
//  XmlRpcValueRepresentable.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

public protocol XmlRpcValueRepresentable {
  init?(xmlRpcValue: XmlRpc.Value)
  var xmlRpcValue : XmlRpc.Value { get }
}

public extension XmlRpc.Call {
  
  @inlinable
  init(_ methodName: String, _ parameters: XmlRpcValueRepresentable...) {
    self.init(methodName, parameters: parameters.map { $0.xmlRpcValue })
  }
}

public extension XmlRpc.Response {
  
  @inlinable
  init(_ value: XmlRpcValueRepresentable) {
    self = .value(value.xmlRpcValue)
  }
}

extension XmlRpc.Value: XmlRpcValueRepresentable {
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) { self = xmlRpcValue }
  
  @inlinable
  public var xmlRpcValue : XmlRpc.Value   { return self }
}

extension String: XmlRpcValueRepresentable {
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    switch xmlRpcValue {
      case .string(let s), .dateTime(let s): self = s
      case .array, .dictionary, .data: return nil
      case .bool  (let flag) : self = flag ? "true" : "false"
      case .int   (let v)    : self = String(describing: v)
      case .double(let v)    : self = String(describing: v)
      case .null             : self = "" // TBD: rather <null>?
    }
  }
  
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .string(self) }
}

extension Int: XmlRpcValueRepresentable {
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    switch xmlRpcValue {
      case .string(let s):
        guard let value = Int(s) else { return nil }
        self = value
      case .array, .dictionary, .data: return nil
      case .dateTime         : return nil // TBD: utime?
      case .bool  (let flag) : self = flag ? 1 : 0
      case .int   (let v)    : self = v
      case .double(let v)    : self = Int(v)
      case .null             : self = 0 // TBD
    }
  }
  
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .int(self) }
}

extension Double: XmlRpcValueRepresentable {
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    switch xmlRpcValue {
      case .string(let s):
        guard let value = Double(s) else { return nil }
        self = value
      case .array, .dictionary, .data: return nil
      case .dateTime         : return nil // TBD: utime?
      case .bool  (let flag) : self = flag ? 1.0 : 0.0
      case .int   (let v)    : self = Double(v)
      case .double(let v)    : self = v
      case .null             : self = 0 // TBD
    }
  }
  
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .double(self) }
}

extension Bool: XmlRpcValueRepresentable {
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    switch xmlRpcValue {
      case .string(let s):
        switch s.lowercased() {
          case "yes", "true", "1", "да" : self = true
          default                       : self = false
        }
      case .array, .dictionary, .data: return nil
      case .dateTime         : return nil
      case .bool  (let flag) : self = flag
      case .int   (let v)    : self = v != 0
      case .double(let v)    : self = v != 0.0
      case .null             : self = false // TBD
    }
  }
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .bool(self) }
}

extension Collection where Element : XmlRpcValueRepresentable {
  
  /**
   * Encoding XML-RPC responses themselves in XML-RPC using the
   * `system.multicall` convention, which says:
   * - render faults as their dictionaries
   * - render values within a single-item array
   */
  @inlinable
  public var xmlRpcValue : XmlRpc.Value { return .array(map { $0.xmlRpcValue }) }
}

extension Array   : XmlRpcValueRepresentable
    where Element : XmlRpcValueRepresentable
{
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    guard case .array(let array) = xmlRpcValue else {
      return nil
    }
    self = array.compactMap { Element.init(xmlRpcValue: $0) } // TBD
    assert(self.count == array.count)
  }
}
extension Set     : XmlRpcValueRepresentable
    where Element : XmlRpcValueRepresentable
{
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    guard case .array(let array) = xmlRpcValue else {
      return nil
    }
    self = Set(array.compactMap { Element.init(xmlRpcValue: $0) }) // TBD
    assert(self.count == array.count)
  }
}

extension Dictionary : XmlRpcValueRepresentable
    where Key       == String,
          Value      : XmlRpcValueRepresentable
{
  
  @inlinable
  public init?(xmlRpcValue: XmlRpc.Value) {
    guard case .dictionary(let dict) = xmlRpcValue else {
      return nil
    }
    
    self.init(minimumCapacity: dict.count)
    for ( key, xmlRpcValue ) in dict {
      guard let value = Value.init(xmlRpcValue: xmlRpcValue) else {
        assertionFailure("could not decode a dictionary value: \(xmlRpcValue)")
        continue
      }
      self[key] = value
    }
  }
  
  @inlinable
  public var xmlRpcValue : XmlRpc.Value {
    var mapped = [ String : XmlRpc.Value ]()
    mapped.reserveCapacity(count)
    for ( key, value ) in self {
      mapped[key] = value.xmlRpcValue
    }
    return .dictionary(mapped)
  }
}

#if canImport(Foundation)
  import struct Foundation.URL
  import struct Foundation.DateComponents
  
  extension DateComponents: XmlRpcValueRepresentable {
    
    @inlinable
    public init?(xmlRpcValue: XmlRpc.Value) {
      guard case .dateTime(let s) = xmlRpcValue else { return nil }
      self.init(xmlRpcString: s)
    }

    @inlinable
    public init?(xmlRpcString s: String) {
      // 19980717T14:08:55
      guard s.count == 17 else { return nil }
      
      let dt = s.split(separator: "T", maxSplits: 1)
      guard dt.count == 2,
            let dates = dt.first, dates.count == 8,
            let times = dt.last,  times.count == 8 else { return nil }
      
      let tc = times.split(separator: ":", maxSplits: 3)
      guard tc.count == 3 else { return nil }
      
      guard let y = Int(dates.dropLast(4)),
            let m = Int(dates.dropFirst(4).dropLast(2)),
            let d = Int(dates.dropFirst(6)) else { return nil }
      
      self.init(year: y, month: m, day: d,
                hour: Int(tc[0]), minute: Int(tc[1]), second: Int(tc[2]))
    }

    @inlinable
    public var xmlRpcValue : XmlRpc.Value {
      // Perf, oohh, perf.
      // 19980717T14:08:55
      func leftpad(_ s: String, _ width: Int) -> String {
        let left = width - s.count
        return left <= 0 ? s : String(repeating: "0", count: left) + s
      }
      var ms = ""
      ms.reserveCapacity(17)
      ms.append(leftpad(String(year   ?? 0), 4))
      ms.append(leftpad(String(month  ?? 0), 2))
      ms.append(leftpad(String(day    ?? 0), 2))
      ms.append("T")
      ms.append(leftpad(String(hour   ?? 0), 2))
      ms.append(":")
      ms.append(leftpad(String(minute ?? 0), 2))
      ms.append(":")
      ms.append(leftpad(String(second ?? 0), 2))
      return .dateTime(ms)
    }
  }

  extension URL: XmlRpcValueRepresentable {

    @inlinable
    public init?(xmlRpcValue: XmlRpc.Value) {
      guard case .string(let s) = xmlRpcValue else { return nil }
      guard let url = URL(string: s)          else { return nil }
      self = url
    }
    
    @inlinable
    public var xmlRpcValue : XmlRpc.Value { return absoluteString.xmlRpcValue }
  }
#endif // canImport(Foundation)
