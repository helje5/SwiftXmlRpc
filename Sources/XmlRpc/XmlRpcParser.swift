//
//  XmlRpcParser.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import struct   Foundation.Data
import class    Foundation.XMLParser
import protocol Foundation.XMLParserDelegate
import class    Foundation.NSObject

public extension XmlRpc { // MARK: - Parser
  
  static func parseCall(_ s: String) -> Call? {
    let parser  = XMLParser(data: Data(s.utf8))
    let handler = Handler()
    parser.delegate = handler
    
    guard parser.parse() else { return nil }
    return handler.call
  }
  
  static func parseResponse(_ s: String) -> Response? {
    let parser  = XMLParser(data: Data(s.utf8))
    let handler = Handler()
    parser.delegate = handler
    guard parser.parse() else { return nil }
    return handler.response
  }
  
  
  private final class Handler: NSObject, XMLParserDelegate {
    
    fileprivate var call     : Call?
    fileprivate var response : Response?
    
    private var cdata           : String?
    private var valueStack      = [ Value? ]()
    private var memberNameStack = [ String ]()
    
    private func startNewValue() {
      valueStack.append(nil)
    }
    private func pop() -> Value? {
      return valueStack.isEmpty ? nil : valueStack.removeLast()
    }
    private var currentValue : Value {
      set {
        guard !valueStack.isEmpty else {
          assertionFailure("no current value!")
          return
        }
        valueStack[valueStack.count - 1] = newValue
      }
      get {
        guard let lastOpt = valueStack.last else { return .null }
        return lastOpt ?? .null
      }
    }
    
    private func consumeCDATA() -> String {
      let value = cdata ?? ""; cdata = nil
      return value
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
      cdata?.append(string)
    }
    
    func parser(_     parser : XMLParser, didStartElement elementName : String,
                namespaceURI : String?,   qualifiedName               : String?,
                attributes   : [ String : String ])
    {
      switch elementName {
        case "methodCall":
          call = Call("")
          
        case "methodResponse":
          assert(valueStack.isEmpty)
          valueStack.removeAll()

        case "methodName":
          cdata = ""
          
        case "fault"  : break // will process on </fault>
      
        case "params" :
          break
          
        case "param":
          assert(valueStack.isEmpty)
          valueStack.removeAll()
          
        case "name":
          assert(cdata?.isEmpty ?? true)
          cdata = ""

        case "value":
          startNewValue()
          cdata = "" // need to collect for "default string"
      
        case "i4", "int", "double", "float", "boolean", "base64", "string":
          assert(cdata?.isEmpty ?? true)
          cdata = ""

        case "dateTime.iso8601":
          assert(cdata?.isEmpty ?? true)
          cdata = ""

        case "array":
          // assert(cdata?.isEmpty ?? true) - can be whitespace
          cdata = nil
          currentValue = .array([])
        case "struct":
          // assert(cdata?.isEmpty ?? true) - can be whitespace
          cdata = nil
          currentValue = .dictionary([:])
          
        case "member", "data": // array/dict element
          break
          
        default:
          assertionFailure("unexpected XML-RPC tag: \(elementName)")
      }
    }
    
    func parser(_     parser : XMLParser, didEndElement elementName : String,
                namespaceURI : String?,   qualifiedName       qName : String?)
    {
      switch elementName {
        case "methodCall":
          assert(call != nil)
          
        case "methodResponse":
          if response == nil {
            guard let value = pop() else {
              assertionFailure("response had no value?!")
              response = .value(.null)
              return
            }
            response = .value(value)
          }
          else { // fault
            #if DEBUG
              guard case .fault = response else {
                assertionFailure("response expected to be a fault?!")
                return
              }
              assert(valueStack.isEmpty)
            #endif
          }
          
        case "methodName":
          call?.methodName = cdata ?? ""
          
        case "fault":
          // translate the dictionary to a fault
          guard let value = pop() else {
            assertionFailure("no value for fault?!")
            response = .fault(.init(code: -1337, reason: "parse error"))
            return
          }
          assert(valueStack.isEmpty, "more than one value on stack?!")
          valueStack.removeAll()
          
          guard case .dictionary(let values) = value else {
            assertionFailure("unexpected value for fault \(value)?!")
            response =
              .fault(.init(code: -1338, reason: "parse error, fault value"))
            return
          }
          guard case .int(let code) = value["faultCode"] else {
            assertionFailure("unexpected values for fault \(values)?!")
            response = .fault(
              .init(code: -1339, reason: "parse error, fault value \(values)"))
            return
          }
          response = .fault(.init(code: code,
                                  reason: value["faultString"].stringValue))

        case "params": // already collected as part of `call`
          break
          
        case "param":
          if call != nil {
            guard let value = pop() else {
              assertionFailure("found no value for parameter!")
              call?.parameters.append(.null)
              return
            }
            assert(valueStack.isEmpty)
            valueStack.removeAll()
            call?.parameters.append(value)
          }

        case "name":
          memberNameStack.append(consumeCDATA())

        case "value":
          let count = valueStack.count
          guard count > 0 else {
            assertionFailure("empty value stack in value-end tag?!")
            return
          }
          if valueStack[count - 1] == .none {
            currentValue = .string(consumeCDATA())
          }
          if count > 1, case .array(var values) = valueStack[count - 2] {
            guard let element = pop() else {
              assertionFailure("got no array element value!")
              return
            }
            values.append(element)
            currentValue = .array(values)
          }
          
        case "null":
          currentValue = .null
      
        case "string":
          currentValue = .string(consumeCDATA())
        case "i4", "int":
          currentValue = .int(Int(consumeCDATA()) ?? 0)
        case "double", "float":
          currentValue = .double(Double(consumeCDATA()) ?? 0)
        case "boolean":
          currentValue = .bool(!(cdata == nil || cdata == "0")); cdata = nil
        case "base64":
          currentValue = .data(Data(base64Encoded: consumeCDATA()) ?? Data())

        case "dateTime.iso8601":
          // Note: We can't really parse this as a date, just components?
          currentValue = .dateTime(consumeCDATA())
          
        case "array":
          break
        case "struct":
          break
          
        case "member":
          let lastName = memberNameStack.popLast()
          
          guard let element = pop() else {
            assertionFailure("got no dict element value \(lastName ?? "-")!")
            return
          }
          guard let name = lastName else {
            assertionFailure("got no dict element name \(element)!")
            return
          }
          guard case .dictionary(var values) = currentValue else {
            assertionFailure("member outside of dictionary!")
            return
          }
          values[name] = element
          currentValue = .dictionary(values)
          
        case "data": // array element
          guard case .array = currentValue else {
            assertionFailure("data outside of array, value=\(currentValue)!")
            return
          }

        default:
          assertionFailure("unexpected XML-RPC tag: \(elementName)")
      }
    }
  }
}
