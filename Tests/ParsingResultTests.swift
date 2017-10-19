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
@testable import Targone

class ParsingResultTests: XCTestCase {

    func testThatItReturnsValuesByArgument() {
        // given
        let argument1 = OptionalArgument<Int>("--foo")
        let argument2 = PositionalArgument<Double>("bar")
        let argument3 = FlagArgument("--no")
        
        // when
        let parsed = ParsingResult(labelsToValues: ["--foo" : 12, "bar" : 50.2, "--no" : true])
        
        // then
        XCTAssertEqual(parsed.value(argument1), Optional<Int>(12))
        XCTAssertEqual(parsed.value(argument2), Optional<Double>(50.2))
        XCTAssertEqual(parsed.value(argument3), Optional<Bool>(true))

    }
    
    func testThatItReturnsNilValuesByArgumentIfTheTypeDoesNotMatch() {
        // given
        let argument1 = OptionalArgument<Int>("--foo")
        let argument2 = PositionalArgument<Double>("bar")
        
        // when
        let parsed = ParsingResult(labelsToValues: ["--foo" : "aa", "bar" : Int(2)])
        
        // then
        XCTAssertNil(parsed.value(argument1))
        XCTAssertNil(parsed.value(argument2))
    }
    
    func testThatItReturnsValueByType() {

        // when
        let parsed = ParsingResult(labelsToValues: ["yes" : true, "no" : false, "number" : 24, "string" : "FOO"])
        
        // then
        XCTAssertEqual(parsed.boolValue("yes"), Optional<Bool>(true))
        XCTAssertEqual(parsed.boolValue("no"), Optional<Bool>(false))
        XCTAssertEqual(parsed.intValue("number"), Optional<Int>(24))
        XCTAssertEqual(parsed.stringValue("string"), Optional<String>("FOO"))
    }
    
    func testThatItReturnsValue() {
        
        // when
        let parsed = ParsingResult(labelsToValues: ["yes" : true, "number" : 24, "string" : "FOO"])
        
        // then
        XCTAssertEqual(parsed.value("yes") as? Bool, Optional<Bool>(true))
        XCTAssertEqual(parsed.value("number") as? Int, Optional<Int>(24))
        XCTAssertEqual(parsed.value("string") as? String, Optional<String>("FOO"))
    }
    
    func testThatItReturnsValueWithCorrectType() {
        
        // when
        let parsed = ParsingResult(labelsToValues: ["yes" : true, "number" : 24, "string" : "FOO"])
        
        // then
        XCTAssertEqual(parsed.value("yes", type: Bool.self) as? Bool, Optional<Bool>(true))
        XCTAssertEqual(parsed.value("number", type: Int.self) as? Int, Optional<Int>(24))
        XCTAssertEqual(parsed.value("string", type: String.self) as? String, Optional<String>("FOO"))
    }
    
    func testThatItDoesNotReturnValuesIfNotPresent() {
        
        // when
        let parsed = ParsingResult(labelsToValues: [:])
        
        // then
        XCTAssertNil(parsed.boolValue("yes"))
        XCTAssertNil(parsed.intValue("number"))
        XCTAssertNil(parsed.stringValue("string"))
        XCTAssertNil(parsed.value("foo"))
    }
}
