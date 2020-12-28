// swift-tools-version:5.0

import PackageDescription

let package = Package(
  
  name: "SwiftXmlRpc",
  
  products: [
    .library(name: "XmlRpc", targets: [ "XmlRpc" ])
  ],
  
  targets: [
    .target    (name: "XmlRpc"),
    .testTarget(name: "XmlRpcTests", dependencies: [ "XmlRpc" ])
  ]
)
