import XCTest
@testable import XmlRpc

public final class XmlRpcParserTests: XCTestCase {
  
  func testCallWithStructArray() throws {
    guard let call = XmlRpc.parseCall(TestData.installCall) else {
      return XCTAssert(false, "failed to parse call!")
    }
    
    XCTAssertEqual(call.methodName, "setInstallModeWithWhitelist")
    XCTAssertEqual(call.parameters.count, 3)
    
    XCTAssertEqual(call[0], true)
    XCTAssertEqual(call[1], 30)
    XCTAssertEqual(call[2].count, 1)
    XCTAssertEqual(call[2][0], [
      "ADDRESS"  : "3014F7XXXXXXXXYYYY8CBEEE",
      "KEY"      : "FBCABCDEFG508A29ABCDEFG413CE9FEF",
      "KEY_MODE" : "LOCAL"
    ])
    XCTAssertEqual(call[2][0]["ADDRESS"], "3014F7XXXXXXXXYYYY8CBEEE")
  }

  func testSimpleCall() throws {
    guard let call = XmlRpc.parseCall(TestData.sampleSumCall) else {
      return XCTAssert(false, "failed to parse call!")
    }
    XCTAssertEqual(call.methodName, "sample.sum")
    XCTAssertEqual(call.parameters.count, 2)
    XCTAssertEqual(call[0], 17)
    XCTAssertEqual(call[1], 13)
  }
  
  func testSimpleResponse() throws {
    guard let r = XmlRpc.parseResponse(TestData.sampleSumResponse) else {
      return XCTAssert(false, "failed to parse response!")
    }
    XCTAssertEqual(r, .value(30))
  }

  func testEmtpyResponse() throws {
    guard let r = XmlRpc.parseResponse(TestData.emptyResponse) else {
      return XCTAssert(false, "failed to parse response!")
    }
    XCTAssertEqual(r, .value("")) // If no type is indicated, the type is string
  }
  
  func testListDevices() throws {
    guard let call = XmlRpc.parseCall(TestData.hmIPListDevices) else {
      return XCTAssert(false, "failed to parse call!")
    }
    XCTAssertEqual(call.methodName, "listDevices")
    XCTAssertEqual(call.parameters.count, 1)
    XCTAssertEqual(call[0], "ZeePusher")
  }
  
  func testMultiCall() throws {
    guard let call = XmlRpc.parseCall(TestData.multiCall) else {
      return XCTAssert(false, "failed to parse call!")
    }
    XCTAssertEqual(call.methodName, "system.multicall")
    XCTAssertEqual(call.parameters.count, 1)
    
    guard case .array(let elements) = call[0] else {
      XCTAssert(false, "expected array, got: \(call[0])")
      return
    }
    
    XCTAssertEqual(elements.count, 4)

    // check first
    
    guard case .some(.dictionary(let subcall)) = elements.first else {
      XCTAssert(false, "unexpected elements: \(elements)")
      return
    }
    print("ELEMENTS:", subcall)
    XCTAssertEqual(subcall["methodName"], "event")
    
    guard case .some(.array(let params)) = subcall["params"] else {
      XCTAssert(false, "unexpected params: \(subcall)")
      return
    }
    XCTAssertEqual(params.count, 4)
    XCTAssertEqual(params[0], "SeePusher")
    XCTAssertEqual(params[1], "LEQ123456:0")
    XCTAssertEqual(params[2], "STICKY_UNREACH")
    XCTAssertEqual(params[3], true)
  }

  
  func testSimpleNestedCall() throws {
    guard let call = XmlRpc.parseCall(TestData.simpleNested) else {
      return XCTAssert(false, "failed to parse call!")
    }
    XCTAssertEqual(call.methodName,       "system.multicall")
    XCTAssertEqual(call.parameters.count, 1)
    
    guard case .array(let elements) = call[0] else {
      XCTAssert(false, "expected array, got: \(call[0])")
      return
    }
    
    XCTAssertEqual(elements.count, 1)
    guard case .some(.dictionary(let subcall)) = elements.first else {
      XCTAssert(false, "unexpected elements: \(elements)")
      return
    }
    XCTAssertEqual(subcall["methodName"], "event")
    
    guard case .some(.array(let params)) = subcall["params"] else {
      XCTAssert(false, "unexpected params: \(subcall)")
      return
    }
    XCTAssertEqual(params.count, 4)
    if params.count > 0 { XCTAssertEqual(params[0], "SeePusher")      }
    if params.count > 1 { XCTAssertEqual(params[1], "LEQ123456:0")    }
    if params.count > 2 { XCTAssertEqual(params[2], "STICKY_UNREACH") }
    if params.count > 3 { XCTAssertEqual(params[3], true)             }
  }

  static var allTests = [
    ( "testCallWithStructArray" , testCallWithStructArray ),
    ( "testSimpleCall"          , testSimpleCall          ),
    ( "testSimpleResponse"      , testSimpleResponse      ),
    ( "testEmtpyResponse"       , testEmtpyResponse       ),
    ( "testListDevices"         , testListDevices         ),
    ( "testMultiCall"           , testMultiCall           ),
    ( "testSimpleNestedCall"    , testSimpleNestedCall    )
  ]
}
