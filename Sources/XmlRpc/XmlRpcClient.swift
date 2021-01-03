//
//  XmlRpcClient.swift
//  XmlRpc
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

#if canImport(Foundation)

import Dispatch
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
    return XmlRpcClient(url: url, encoding: encoding, session: session)
  }
  
  /**
   * Create a new `XmlRpcClient` object for the given URL.
   */
  @inlinable
  static func createClient(_    url : String,
                           encoding : String.Encoding? = .isoLatin1,
                           session  : URLSession       = .shared)
              -> XmlRpcClient
  {
    let parsedURL = URL(string: url) ?? {
      assertionFailure("invalid URL passed to `createClient`: \(url)")
      return URL(string: "invalid://url")!
    }()
    return createClient(parsedURL, encoding: encoding, session: session)
  }
}

/**
 * A simple XML-RPC client.
 *
 * Blocking call:
 *
 *     let client = XmlRpc.createClient("http://ccuw:2001/RPC2")
 *     try client.system.listMethods()
 *
 * Asynchronously call an XML-RPC function with the given parameters:
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
@dynamicMemberLookup
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
  
  @usableFromInline
  let authorization : String
  
  @inlinable
  public init(url           : URL,
              encoding      : String.Encoding? = .isoLatin1,
              authorization : String           = "",
              session       : URLSession       = .shared)
  {
    self.url           = url
    self.session       = session
    self.encoding      = encoding
    self.authorization = authorization
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
    
    if let charset = encoding?.contentTypeCharset {
      req.addValue("text/xml; charset=\"\(charset)\"",
                   forHTTPHeaderField: "Content-Type")
    }
    else {
      req.addValue("text/xml", forHTTPHeaderField: "Content-Type")
    }
    
    let content = Data(call.xmlString.utf8)
    req.addValue("\(content.count)", forHTTPHeaderField: "Content-Length")
    
    req.httpBody = content
    
    if !authorization.isEmpty {
      req.addValue(authorization, forHTTPHeaderField: "Authorization")
    }
    
    let encoding = self.encoding
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
  
  
  // MARK: - Dynamic Callable
  
  /**
   * This represents an XML-RPC function name, coupled with the client
   * (endpoint) it lives at. It does not carry the arguments.
   *
   * Method names can be namespaced in XML-RPC, e.g. `system.listMethods`.
   *
   * When used as a call, this will _block_ until the request has completed.
   *
   * Example:
   *
   *     let client = XmlRpc.createClient("http://ccuw:2001/RPC2")
   *     try client.system.listMethods()
   * 
   */
  @dynamicCallable
  @dynamicMemberLookup
  public struct FunctionSelector {
    
    public let client     : XmlRpcClient
    public let methodName : String
    
    @inlinable
    public init(client: XmlRpcClient, methodName: String) {
      self.client     = client
      self.methodName = methodName
    }
    
    @inlinable
    public subscript(dynamicMember key: String) -> XmlRpcClient.FunctionSelector {
      return FunctionSelector(client     : client,
                              methodName : methodName + "." + key)
    }

    @discardableResult
    public func dynamicallyCall(withArguments
                                  arguments: [ XmlRpcValueRepresentable ])
                  throws -> XmlRpc.Value
    {
      let methodCall = XmlRpc.Call(methodName,
                                   parameters: arguments.map { $0.xmlRpcValue })
      
      // This is not great, but it'll become great once async/await arrives ;-)
      let semaphore = DispatchSemaphore(value: 0)
      
      var result : Result<XmlRpc.Value, Swift.Error>?

      let client = self.client
      DispatchQueue.global().async {
        client.call(methodCall) { error, value in
          if let error = error { result = .failure(error) }
          else                 { result = .success(value) }
          semaphore.signal()
        }
      }
      
      semaphore.wait()

      switch result {
        case .failure(let error) : throw error
        case .success(let value) : return value
        case .none               : return .null
      }
    }
  }
  
  @inlinable
  public subscript(dynamicMember key: String) -> XmlRpcClient.FunctionSelector {
    return FunctionSelector(client: self, methodName: key)
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

internal extension String.Encoding {
  
  @usableFromInline
  var contentTypeCharset: String? {
    switch self {
      case .utf8      : return "UTF-8"
      case .isoLatin1 : return "ISO-8859-1"
      default         : return nil
    }
  }
}

#endif // canImport(Foundation)
