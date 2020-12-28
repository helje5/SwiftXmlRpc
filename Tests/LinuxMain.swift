import XCTest
import XmlRpcTests

var tests = [ XCTestCaseEntry ]()
tests += XmlRpcParserTests    .allTests()
tests += XmlRpcGenerationTests.allTests()
XCTMain(tests)
