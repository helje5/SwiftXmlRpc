// swift-tools-version:5.0

import PackageDescription

let package = Package(
  
  name: "SwiftXmlRpc",
  
  products: [
    .library   (name: "XmlRpc",      targets: [ "XmlRpc"      ]),
    .executable(name: "xmlrpc_call", targets: [ "xmlrpc_call" ])
  ],
  
  targets: [
    .target    (name: "XmlRpc"),
    .target    (name: "xmlrpc_call", dependencies: [ "XmlRpc" ]),
    .testTarget(name: "XmlRpcTests", dependencies: [ "XmlRpc" ])
  ]
)
