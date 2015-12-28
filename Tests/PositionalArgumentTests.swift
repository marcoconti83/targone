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

class PositionalArgumentTests: XCTestCase {
    
}

// MARK: - Label

extension PositionalArgumentTests {
    
    func testThatAnArgumentStartingWithDashDashThrowsIfPositional() {
        
        // when
        do {
            _ = try PositionalArgument<Int>(label: "--number")
            XCTFail("Did not throw")
        } catch ArgumentInitError.LabelCanNotBeFlagIfArgumentIsPositional{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnArgumentStartingWithDashThrowsIfPositional() {
        
        // when
        do {
            _ = try PositionalArgument<Int>(label: "-n")
            XCTFail("Did not throw")
        } catch ArgumentInitError.LabelCanNotBeFlagIfArgumentIsPositional{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnInvalidLabelThrows() {
        
        // when
        do {
            _ = try PositionalArgument<Int>(label: "-n  ds")
            XCTFail("Did not throw")
        } catch ArgumentInitError.InvalidLabel{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatItReturnsTheLabel() {
        
        // given
        let sut = PositionalArgument<Int>("foo")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["foo"]))
    }
}

// MARK: - Description

extension PositionalArgumentTests {
    
    func testExpectedPositionalDescription() {
        
        do {
            let sut = PositionalArgument<Int>("foo", help: "help help")
            XCTAssertEqual(sut.description, "foo<Int>                      help help")
        }
        do {
            let sut = PositionalArgument<Int>("foo")
            XCTAssertEqual(sut.description, "foo<Int>")
        }
    }
    
    func testDescriptionWithFlagLongerThanPadding() {
        
        // given
        let label = "foooooooooooooooooooooooooooooooooooo"
        let help = "This is the help"
        let sut = PositionalArgument<Int>(label, help: help)
        let expected = "\(label)<Int> \(help)"
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, expected)
    }
}


// MARK: - Parsing

extension PositionalArgumentTests {

    func testThatItReturnsTheValueWhenParsingAValidInt() {
        
        // given
        let sut = PositionalArgument<Int>("foo")
        
        // when
        let parsed = try! sut.parseValue("34") as? Int
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, 34)
        }
    }
    
    func testThatItThrowsWhenParsingAnInvalidInt() {
        
        // given
        let value = "34.2"
        let sut = PositionalArgument<Int>("foo")
        
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.InvalidType(let argument, let token) {
            // then
            XCTAssertEqual(argument, sut)
            XCTAssertEqual(token, value)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAString() {
        
        // given
        let value = "34.2"
        let sut = PositionalArgument<String>("foo")
        
        // when
        let parsed = try! sut.parseValue(value) as? String
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, value)
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAValidDouble() {
        
        // given
        let sut = PositionalArgument<Double>("foo")
        
        // when
        let parsed = try! sut.parseValue("34.2") as? Double
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, 34.2)
        }
    }
    
    func testThatItReturnsNilWhenParsingAnInvalidDouble() {
        
        // given
        let value = "34.2a"
        let sut = PositionalArgument<Double>("foo")
        
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.InvalidType(let argument, let token) {
            // then
            XCTAssertEqual(argument, sut)
            XCTAssertEqual(token, value)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAValidTrueBool() {
        
        // given
        let sut = PositionalArgument<Bool>("foo")
        
        for value in ["TRUE","true","1"] {
            // when
            let parsed = try! sut.parseValue(value) as? Bool
            
            // then
            XCTAssertNotNil(parsed)
            if let parsed = parsed {
                XCTAssertTrue(parsed)
            }
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAValidFalseBool() {
        
        // given
        let sut = PositionalArgument<Bool>("foo")
        
        for value in ["FALSE","false","0"] {
            // when
            let parsed = try! sut.parseValue(value) as? Bool
            
            // then
            XCTAssertNotNil(parsed)
            if let parsed = parsed {
                XCTAssertFalse(parsed)
            }
        }
    }
    
    func testThatItReturnsNilWhenParsingAnInvalidBool() {
        
        // given
        let value = "24"
        let sut = PositionalArgument<Bool>("foo")
        
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.InvalidType(let argument, let token) {
            // then
            XCTAssertEqual(argument, sut)
            XCTAssertEqual(token, value)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItReturnsNilWhenParsingAValueThatIsNotInTheChoices() {
        
        // given
        let choices = [2,4,8,16]
        let value = "24"
        let sut = PositionalArgument<Int>("foo", choices: choices)
        
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.NotInChoices(let argument, let validChoices, let token) {
            // then
            XCTAssertEqual(argument, sut)
            XCTAssertEqual(token, value)
            XCTAssertEqual(validChoices.map { $0 as! Int}, choices)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testThatItParsesAnOptionalValueThatIsInTheChoices() {
        
        // given
        let choices = [2,4,8,16]
        let sut = PositionalArgument<Int>("foo", choices: choices)
        
        // when
        if let parsed = try! sut.parseValue("4") as? Int {
            
            // then
            XCTAssertEqual(parsed, 4)
        }
        else {
            XCTFail()
        }
    }
}

// MARK: - Types

extension PositionalArgumentTests {
    
    func testThatTheExpectedTypesMatches() {
        XCTAssertTrue(PositionalArgument<Int>("foo").expectedType == Int.self)
        XCTAssertTrue(PositionalArgument<Bool>("foo").expectedType == Bool.self)
        XCTAssertTrue(PositionalArgument<String>("foo").expectedType == String.self)
    }
}

