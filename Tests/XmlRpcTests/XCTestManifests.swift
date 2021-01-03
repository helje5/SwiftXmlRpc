import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [ XCTestCaseEntry ] {
  return [
    testCase(XmlRpcGenerationTests.allTests),
    testCase(XmlRpcParserTests    .allTests)
  ]
}
#endif
