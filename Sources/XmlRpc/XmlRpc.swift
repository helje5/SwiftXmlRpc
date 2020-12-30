//
//  XmlRpc.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data

public enum XmlRpc {} // Namespace declaration

public extension XmlRpc { // MARK: - Values

  /**
   * The various possible XML-RPC value types.
   */
  @frozen
  enum Value: Hashable {
    
    case null
    case string    (String)
    case bool      (Bool)
    case int       (Int)
    case double    (Double)
    case dateTime  (String) // TBD, timezone? Use DateComponents?
    case data      (Data)   // base64
    
    case array     ([ Value ])
    case dictionary([ String : Value ])
  }
  
  /**
   * Structure representing an XML-RPC call.
   * 
   * An XML-RPC call is a method name (like `add`) and an array of parameters
   * (like `[1, "hello", 42]`)
   */
  @frozen
  struct Call: Equatable, CustomStringConvertible {
    
    public var methodName = ""
    public var parameters = [ Value ]()
    
    @inlinable
    public init(_ methodName: String, _ parameters: Value...) {
      self.init(methodName, parameters: parameters)
    }
    @inlinable
    public init(_ methodName: String, parameters: [ Value ]) {
      self.methodName = methodName
      self.parameters = parameters
    }
    
    /**
     * Access a call parameter by index.
     */
    @inlinable
    public subscript(parameter: Int) -> Value {
      guard parameter >= 0 && parameter < parameters.count else {
        return .null
      }
      return parameters[parameter]
    }
    
    public var description: String {
      return methodName
           + "(" + parameters.map(\.description).joined(separator: ", ") + ")"
    }
  }
  
  /**
   * An XML-RPC "Fault", i.e. an error.
   * 
   * In XML-RPC an error has an integer code and a reason string.
   */  
  @frozen
  struct Fault: Swift.Error, Equatable {
    
    public let code   : Int
    public let reason : String
    
    @inlinable
    public init(code: Int, reason: String? = nil) {
      self.code   = code
      self.reason = reason ?? "Call failed with code: \(code)"
    }
  }
  
  /**
   * Enum representing an XML-RPC response.
   * 
   * An XML-RPC response is either a `Fault` or some `Value`.
   */
  @frozen
  enum Response: Equatable {
    case fault(Fault)
    case value(Value)
  }
}

extension XmlRpc.Value : CustomStringConvertible {

  @inlinable
  public var description: String {
    switch self {
      case .null               : return  "<null>"
      case .string  (let s)    : return "\"\(s)\""
      case .bool    (let flag) : return flag ? "YES" : "NO"
      case .int     (let v)    : return "\(v)"
      case .double  (let v)    : return "\(v)"
      case .dateTime(let v)    : return "\(v)"
      case .data    (let v)    : return "<Data: #\(v.count)>"
        
      case .array(let elements):
        return "[ \(elements.map(\.description).joined(separator: ", ")) ]"
        
      case .dictionary(let values):
        var ms = "{ "
        values.forEach { key, value in
          ms += " \(key) = \(value.description);"
        }
        ms += " }"
        return ms
    }
  }
}
