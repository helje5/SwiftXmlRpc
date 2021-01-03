# Swift XML-RPC

XML-RPC protocol support for Swift.

An XML-RPC parser and a simple XML-RPC client object based upon `URLSession`
(if available).

Performing a simple call:
```swift
#!/usr/bin/swift sh
import XmlRpc // AlwaysRightInstitute/SwiftXmlRpc

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
the
[Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like 
[feedback](https://twitter.com/ar_institute), 
GitHub stars, 
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
