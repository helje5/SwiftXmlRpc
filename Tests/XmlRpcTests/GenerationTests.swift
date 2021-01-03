import XCTest
@testable import XmlRpc

final class XmlRpcGenerationTests: XCTestCase {
  
  func testSimpleCallGeneration() {
    let call   = XmlRpc.Call("examples.getStateName", 41)
    let xml    = call.xmlString
    let parsed = XmlRpc.parseCall(xml)
    XCTAssertEqual(parsed?.methodName,       "examples.getStateName")
    XCTAssertEqual(parsed?.parameters.first, 41)
    
    XCTAssertEqual(xml, parsed?.xmlString)
  }
  
  func testSimpleResponseGeneration() {
    let call = XmlRpc.Response.value("South Dakota")
    let xml = call.xmlString
    
    let parsed = XmlRpc.parseResponse(xml)
    guard case .some(.value(let value)) = parsed else {
      return XCTAssert(false, "got no value! \(parsed as Any)")
    }
    
    XCTAssertEqual(value, "South Dakota")
    XCTAssertEqual(xml, parsed?.xmlString)
  }

  func testArrayStructCallGeneration() {
    let call   = XmlRpc.Call("register", true, [ [ "key": "value" ] ])
    let xml    = call.xmlString
    let parsed = XmlRpc.parseCall(xml)
    XCTAssertEqual(parsed?.methodName       , "register")
    XCTAssertEqual(parsed?.parameters.first , true)
    XCTAssertEqual(parsed?.parameters.last  , [ [ "key": "value" ] ])

    XCTAssertEqual(xml, parsed?.xmlString)
  }
  
  static var allTests = [
    ( "testSimpleCallGeneration"      , testSimpleCallGeneration      ),
    ( "testSimpleResponseGeneration"  , testSimpleResponseGeneration  ),
    ( "testArrayStructCallGeneration" , testArrayStructCallGeneration )
  ]
}
