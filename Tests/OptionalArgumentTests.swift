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

class OptionalArgumentTests: XCTestCase {
    
}

// MARK: - Label

extension OptionalArgumentTests {
    
    func testThatItDoesNotRemoveDashesFromLabels() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = OptionalArgument<Int>(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, [longLabel, shortLabel])
        XCTAssertEqual(argument.label, longLabel)
    }
    
    func testThatItDoesAddDashesToLabels() {
        
        // given
        let shortLabel = "n"
        let longLabel = "number"
        
        // when
        let argument = OptionalArgument<Int>(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, ["--number","-n"])
        XCTAssertEqual(argument.label, "--number")
    }

    func testThatItUsesShortLabelAsCompactLabel() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = OptionalArgument<Int>(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.compactLabel, "-n")
    }
    
    func testThatItUseLabelAsCompactLabelIfThereIsNoShortLabel() {
        
        // given
        let longLabel = "--number"
        
        // when
        let argument = OptionalArgument<Double>(longLabel)
        
        // then
        XCTAssertEqual(argument.compactLabel, "--number")
    }
    
    func testThatShortLabelCanNotBeLongFlag() {
        // when
        do {
            _ = try OptionalArgument<Int>(label: "--number", shortLabel: "--number")
            XCTFail("Did not throw")
        } catch ArgumentInitError.ShortLabelCanNotBeLongFlag{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatLabelCanBeShortFlag() {
        // when
        do {
            _ = try OptionalArgument<Int>(label: "-n")
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnInvalidLabelThrows() {
        
        // when
        do {
            _ = try OptionalArgument<Int>(label: "-n  ds")
            XCTFail("Did not throw")
        } catch ArgumentInitError.InvalidLabel{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnInvalidShortLabelThrows() {
        
        // when
        do {
            _ = try OptionalArgument<Int>(label: "--num", shortLabel: "-n s")
            XCTFail("Did not throw")
        } catch ArgumentInitError.InvalidLabel{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatItReturnsAllLabelsWhenBothAreSet() {
        
        // given
        let sut = OptionalArgument<Int>("--number", shortLabel: "-n")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["--number","-n"]))
    }
    
    func testThatItReturnsAllLabelsWhenOneIsSet() {
        
        // given
        let sut = OptionalArgument<Int>("--number")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["--number"]))
    }
    
    func testThatHashOfCommandWithoutShortLabelIsDifferentThanCommandWithShortLabel() {
        
        // given
        let arg1 = OptionalArgument<Int>("foo")
        let arg2 = OptionalArgument<Int>("foo", shortLabel: "f")
        
        // then
        XCTAssertNotEqual(arg1.hashValue, arg2.hashValue)
    }
}

// MARK: - Description

extension OptionalArgumentTests {

    func testExpectedDescription() {
        
        do {
            let sut = OptionalArgument<Int>("--boo", shortLabel: "-b", help: "help help")
            XCTAssertEqual(sut.description, "--boo, -b BOO<Int>            help help")
        }
        do {
            let sut = OptionalArgument<Int>("--boo")
            XCTAssertEqual(sut.description, "--boo BOO<Int>")
        }
    }
    
    func testDescriptionWithFlagLongerThanPadding() {
        
        // given
        let label = "--foooooooooooooooooooooooooooooooooooo"
        let help = "This is the help"
        let sut = OptionalArgument<Int>(label, help: help)
        let expected = "\(label) \(label.placeholderArgumentString())<Int> \(help)"
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, expected)
    }
    
    func testExpectedDescriptionWithChoices() {
        
        // given
        let label = "--foo"
        let help = "This is the help"
        let choices = [34,45,675]
        let choicesDescription = choices.map {"'\($0)'"}.joinWithSeparator(" | ")
        let sut = OptionalArgument<Int>(label, help: help, choices: choices)
        
        let expected = "\(label) \(label.placeholderArgumentString())<Int>                \(help)\n\t\tPossible values: \(choicesDescription)"
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, expected)
        
    }
}


// MARK: - Parsing

extension OptionalArgumentTests {

    func testThatItReturnsTheValueWhenParsingAValidInt() {
        
        // given
        let sut = OptionalArgument<Int>("foo")
        
        // when
        let parsed = try! sut.parseValue("34") as? Int
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, 34)
        }
    }
    
    func testThatItReturnsNilWhenParsingAnInvalidInt() {
        
        // given
        let value = "34.2"
        let sut = OptionalArgument<Int>("foo")
        
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.InvalidType(let argument, let token) {
            XCTAssertEqual(argument, sut)
            XCTAssertEqual(token, value)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAString() {
        
        // given
        let sut = OptionalArgument<String>("foo")
        
        // when
        let parsed = try! sut.parseValue("34a") as? String
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, "34a")
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAValidDouble() {
        
        // given
        let sut = OptionalArgument<Double>("foo")
        
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
        let sut = OptionalArgument<Double>("foo")
        
        // when
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.InvalidType(let argument, let token) {
            XCTAssertEqual(argument, sut)
            XCTAssertEqual(token, value)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAValidTrueBool() {
        
        // given
        let sut = OptionalArgument<Bool>("foo")
        
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
        let sut = OptionalArgument<Bool>("foo")
        
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
        let sut = OptionalArgument<Bool>("foo")
        
        // when
        do {
            try sut.parseValue(value)
        } catch CommandLineArgumentParsingError.InvalidType(let argument, let token) {
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
        let sut = OptionalArgument<Int>("--foo", choices: [2,4,8,16])
        
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
    
    func testThatItParsesAValueThatIsInTheChoices() {
        
        // given
        let sut = OptionalArgument<Int>("--foo", choices: [2,4,8,16])
        
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

extension OptionalArgumentTests {
    
    func testThatTheExpectedTypesMatches() {
        XCTAssertTrue(OptionalArgument<Int>("foo").expectedType == Int.self)
        XCTAssertTrue(OptionalArgument<Bool>("foo").expectedType == Bool.self)
        XCTAssertTrue(OptionalArgument<String>("--foo").expectedType == String.self)
    }
}

