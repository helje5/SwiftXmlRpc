//
//  XmlRpcGeneration.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

fileprivate extension String {
  
  var xmlEscapedStringValue: String {
    return self
      .replacingOccurrences(of: "&",  with: "&amp;")
      .replacingOccurrences(of: "<",  with: "&lt;")
      .replacingOccurrences(of: ">",  with: "&gt;")
      .replacingOccurrences(of: "'",  with: "&apos;")
      .replacingOccurrences(of: "\"", with: "&quot;")
  }
}

public extension XmlRpc.Call {

  var xmlString: String {
    var ms = ""
    ms.reserveCapacity(1000)
    ms.append("<?xml version=\"1.0\"?>\n")
    ms.append("<methodCall><methodName>")
    ms.append(methodName.xmlEscapedStringValue)
    ms.append("</methodName><params>")
    for param in parameters {
      ms.append("<param>")
      param.appendToXmlRpcString(&ms)
      ms.append("</param>")
    }
    ms.append("</params></methodCall>")
    return ms
  }
}

public extension XmlRpc.Response {
  
  var xmlString: String {
    var ms = ""
    ms.reserveCapacity(1000)
    ms.append("<?xml version=\"1.0\"?>\n")
    switch self {
      case .fault(let fault):
        ms.append("<methodResponse><fault><value><struct>")
        ms.append("<member><name>faultCode</name>")
        ms.append("<value><int>\(fault.code)</int></value></member>")
        ms.append("<member><name>faultString</name>")
        ms.append("<value><string>")
        ms.append(fault.reason.xmlEscapedStringValue)
        ms.append("</string></value></member>")
        ms.append("</struct></value></fault></methodResponse>")
      case .value(let value):
        ms.append("<methodResponse><params><param>")
        value.appendToXmlRpcString(&ms)
        ms.append("</param></params></methodResponse>")
    }
    return ms
  }
}

public extension XmlRpc.Value {
  
  func appendToXmlRpcString(_ xml: inout String, supportsNull: Bool = false) {
    switch self {
      case .null:
        xml.append(supportsNull ? "<value><null/></value>" : "<value/>")
        
      case .string(let s):
        xml.append("<value><string>")
        xml.append(s.xmlEscapedStringValue)
        xml.append("</string></value>")

      case .bool(let flag):
        xml.append(flag ? " <value><boolean>1</boolean></value>"
                        : " <value><boolean>0</boolean></value>")
        
      case .int     (let v):
        xml.append("<value><i4>\(v)</i4></value>")
      case .double  (let v):
        xml.append("<value><double>\(v)</double></value>")
        
      case .dateTime(let v):
        xml.append("<value><dateTime.iso8601>\(v)</dateTime.iso8601></value>")
        
      case .data(let v):
        xml.append("<value><base64>")
        xml.append(v.base64EncodedString())
        xml.append("</base64></value>")
        
      case .array(let elements):
        xml.append("<value><array><data>")
        for element in elements {
          element.appendToXmlRpcString(&xml, supportsNull: supportsNull)
        }
        xml.append("</data></array></value>")
      case .dictionary(let values):
        xml.append("<value><struct>")
        
        for ( key, value ) in values {
          xml.append("<member><name>")
          xml.append(key.xmlEscapedStringValue)
          xml.append("</name>")
          value.appendToXmlRpcString(&xml, supportsNull: supportsNull)
          xml.append("</member>")
        }
        xml.append("</struct></value>")
    }
  }
}
