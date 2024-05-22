# Swift XML-RPC

XML-RPC protocol support for Swift.

An XML-RPC parser and a simple XML-RPC client object based upon `URLSession`
(if available).

Performing a simple call:
```swift
#!/usr/bin/swift sh
import XmlRpc // helje5/SwiftXmlRpc

let client  = XmlRpc.createClient("https://www.xmlrpc.com/RPC2")
let methods = try client.system.listMethods()
```

The package also contains a small XML-RPC commandline client.
It can be invoked like that:
```bash
swift run xmlrpc_call "http://yourserver/RPC2" system.listMethods
```

Learn more about XML-RPC in Swift in our blog article:
[Writing an Swift XML-RPC Server](https://www.alwaysrightinstitute.com/macro-xmlrpc/).

Note: Being so old many XML-RPC services still in use are 
using the ISO Latin 1 charset, which is why the client 
defaults to that. 
When interfacing with a newer service, the encoding parameter 
in createClient may have to be used to configure it for UTF-8.

### Links

- [Writing an Swift XML-RPC Server](https://www.alwaysrightinstitute.com/macro-xmlrpc/)
- [XML-RPC](http://xmlrpc.com).com
  - [Spec](http://xmlrpc.com/spec.md)
  - [Original Site](http://1998.xmlrpc.com)
- [XML-RPC Introspection](http://xmlrpc-c.sourceforge.net/introspection.html)
- [NGXmlRpc](http://svn.opengroupware.org/SOPE/trunk/sope-appserver/NGXmlRpc/)
- [xmlrpc_call](http://svn.opengroupware.org/SOPE/trunk/xmlrpc_call/)

### Who

**Swift XML-RPC** is brought to you by
[Helge Heß](https://github.com/helje5/) / [ZeeZide](https://zeezide.de).
We like feedback, GitHub stars, cool contract work, 
presumably any form of praise you can think of.

**Want to support my work**?
Buy an [app](https://zeezide.de/en/products/products.html):
[Code for SQLite3](https://apps.apple.com/us/app/code-for-sqlite3/id1638111010/),
[Past for iChat](https://apps.apple.com/us/app/past-for-ichat/id1554897185),
[SVG Shaper](https://apps.apple.com/us/app/svg-shaper-for-swiftui/id1566140414),
[HMScriptEditor](https://apps.apple.com/us/app/hmscripteditor/id1483239744).
You don't have to use it! 😀
