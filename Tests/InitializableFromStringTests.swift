//Copyright (c) Marco Conti 2015
//
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


import XCTest

class InitializableFromStringTests: XCTestCase {

    func testThatIntIsParsable() {
        XCTAssertEqual(Int(initializationString: "12"), 12)
        XCTAssertEqual(Int(initializationString: "0"), 0)
        XCTAssertEqual(Int(initializationString: "-3"), -3)
    }
    
    func testThatIntDoesNotParseInvalidStrings() {
        XCTAssertEqual(Int(initializationString: "ab"), nil)
        XCTAssertEqual(Int(initializationString: ""), nil)
        XCTAssertEqual(Int(initializationString: "3.4"), nil)
    }
    
    func testThatDoubleIsParsable() {
        XCTAssertEqual(Double(initializationString: "12.3"), 12.3)
        XCTAssertEqual(Double(initializationString: "-3"), -3)
        XCTAssertEqual(Double(initializationString: "0"), 0)
    }
    
    func testThatDoubleDoesNotParseInvalidStrings() {
        XCTAssertEqual(Double(initializationString: "ab"), nil)
        XCTAssertEqual(Double(initializationString: ""), nil)
    }

    func testThatBoolIsParsable() {
        XCTAssertEqual(Bool(initializationString: "1"), true)
        XCTAssertEqual(Bool(initializationString: "true"), true)
        XCTAssertEqual(Bool(initializationString: "TRUE"), true)
        XCTAssertEqual(Bool(initializationString: "0"), false)
        XCTAssertEqual(Bool(initializationString: "false"), false)
        XCTAssertEqual(Bool(initializationString: "FALSE"), false)
    }
    
    func testThatBoolDoesNotParseInvalidStrings() {
        XCTAssertEqual(Bool(initializationString: "ab"), nil)
        XCTAssertEqual(Bool(initializationString: "3.4"), nil)
    }
}
