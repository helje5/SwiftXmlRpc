//
//  xmlrpc_call.swift
//  xmlrpc_call
//
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Foundation
import XmlRpc

let args = ProcessInfo.processInfo.arguments

func usage(exitcode code: Int32 = 0) -> Never {
  print("Usage: \(args.first ?? "xmlrpc_call") <url> <method> [arguments]")
  exit(code)
}

guard args.count >= 3 else { usage(exitcode: 1) }

guard let url = URL(string: args[1]) else {
  print("Invalid URL:", args[1])
  exit(2)
}

let invocation = XmlRpc.Call(
  args[2],
  parameters: args[3...].map { XmlRpc.Value($0) }
)

let client = XmlRpcClient(url: url)

func handleError(_ error: XmlRpcClient.ClientError) -> Never {
  switch error {
    case .couldNotDecodeDataAsString:
      print("Could not decode the returned Data into a String.")
      exit(11)
      
    case .fault(let fault):
      print("An XML-RPC fault was returned:", fault)
      exit(12)
      
    case .invalidXmlRpcResponse(let content):
      print("Endpoint response could not be parsed as XML-RPC:",
            "\n----\n\(content)\n---")
      exit(13)
      
    case .noContentInResponse:
      print("The endpoint returned no content")
      exit(14)
      
    case .httpError(let status, let headers):
      switch status {
        case 403:
          print("Access to endpoint forbidden: HTTP 403")
          exit(43)
        case 404:
          print("Did not find endpoint: HTTP 404")
          exit(44)
        case 401:
          print("Authentication error:",
                (headers["Www-Authenticate"] as? String) ?? "no-authenticate")
          exit(41)
        case 500:
          print("Server error: HTTP 500")
          exit(50)
        default:
          print("HTTP endpoint error:", status, headers)
          exit(20)
      }
      
    case .transportError(let error):
      print("An URLSession error occurred:", error)
      exit(15)
  }
  print("Call failed with error:", error)
  exit(10)
}

client.call(invocation) { error, value in
  if let error = error {
    handleError(error)
  }

  print("Result:", value)
  exit(0)
}

RunLoop.main.run()
