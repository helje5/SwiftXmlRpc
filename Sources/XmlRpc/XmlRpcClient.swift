//
//  XmlRpcClient.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

#if canImport(Foundation)

import struct Foundation.URL
import struct Foundation.Data

#if canImport(FoundationNetworking)
  import class  FoundationNetworking.URLSession
  import struct FoundationNetworking.URLRequest
  import class  FoundationNetworking.HTTPURLResponse
#else
  import class  Foundation.URLSession
  import struct Foundation.URLRequest
  import class  Foundation.HTTPURLResponse
#endif

public extension XmlRpc {
  
  /**
   * Create a new `XmlRpcClient` object for the given URL.
   */
  @inlinable
  static func createClient(_    url : URL,
                           encoding : String.Encoding? = .isoLatin1,
                           session  : URLSession       = .shared)
              -> XmlRpcClient
  {
    return XmlRpcClient(url: url, session: session)
  }
}

/**
 * A simple XML-RPC client.
 */
public struct XmlRpcClient {
  
  public enum ClientError: Swift.Error {
    case transportError            (Swift.Error)
    case httpError                 (status: Int, headers: [AnyHashable : Any])
    case noContentInResponse
    case couldNotDecodeDataAsString(Data, encoding: String.Encoding)
    case invalidXmlRpcResponse     (content: String)
    case fault                     (XmlRpc.Fault)
  }
  
  public let url      : URL
  public let session  : URLSession
  public let encoding : String.Encoding?
  
  @inlinable
  public init(url: URL, encoding: String.Encoding? = .isoLatin1,
              session: URLSession = .shared)
  {
    self.url      = url
    self.session  = session
    self.encoding = encoding
  }
  
  /**
   * Call an XML-RPC function with the given parameters.
   *
   * Example:
   *
   *     let methodCall = XmlRpc.Call("system.listMethods")
   *     client.call(methodCall) { error, value in
   *       if let error = error {
   *         print("Call failed with error:", error)
   *       }
   *       else {
   *         print("Result:", value)
   *       }
   *     }
   *
   */
  @inlinable
  public func call(_ call: XmlRpc.Call,
                   yield: @escaping ( ClientError?, XmlRpc.Value ) -> Void)
  {
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.httpBody = Data(call.xmlString.utf8)
        
    let task = session.dataTask(with: req) { data, response, error in
      if let error = error {
        print("ERROR:", error, response as Any, data as Any)
        return yield(.transportError(error), nil)
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        guard httpResponse.statusCode == 200 else { // only valid thing for XR
          return yield(.httpError(status  : httpResponse.statusCode,
                                  headers : httpResponse.allHeaderFields), nil)
        }
      }
      
      guard let data = data else {
        print("WARN: got no data for XML-RPC request?", response as Any)
        return yield(.noContentInResponse, nil)
      }
      
      guard let s = String(data: data, encoding: encoding ?? .utf8) else {
        print("WARN: got no data for XML-RPC request?", response as Any)
        return yield(.couldNotDecodeDataAsString(data,
                                                 encoding: encoding ?? .utf8),
                     nil)
      }
      
      guard let response = XmlRpc.parseResponse(s) else {
        return yield(.invalidXmlRpcResponse(content: s), nil)
      }
      
      switch response {
        case .fault(let fault): yield(.fault(fault), nil)
        case .value(let value): yield(nil, value)
      }
    }
    
    task.resume()
  }
}

public extension XmlRpcClient {
  
  /**
   * Call an XML-RPC function with the given parameters.
   *
   * Example:
   *
   *     client.call("system.listMethods") { error, value in
   *       if let error = error {
   *         print("Call failed with error:", error)
   *       }
   *       else {
   *         print("Result:", value)
   *       }
   *     }
   *
   */
  @inlinable
  func call(_ methodName: String, _ parameters: XmlRpcValueRepresentable...,
            yield: @escaping (XmlRpcClient.ClientError?, XmlRpc.Value) -> Void)
  {
    let call = XmlRpc.Call(methodName, parameters: parameters.map {
      $0.xmlRpcValue
    })
    self.call(call, yield: yield)
  }
}

#endif // canImport(Foundation)
