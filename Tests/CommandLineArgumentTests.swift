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

class CommandLineArgumentTests: XCTestCase {
    
}


// MARK: - Label

extension CommandLineArgumentTests {

    func testThatItDoesNotRemoveDashesFromOptionalLabels() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = OptionalArgument<Int>(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, [longLabel, shortLabel])
        XCTAssertEqual(argument.label, longLabel)
    }
    
    func testThatItDoesAddDashesToOptionalLabels() {
        
        // given
        let shortLabel = "n"
        let longLabel = "number"
        
        // when
        let argument = OptionalArgument<Int>(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, ["--number","-n"])
        XCTAssertEqual(argument.label, "--number")
    }
    
    func testThatItDoesNotRemoveDashesFromFlagLabels() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = FlagArgument(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, [longLabel, shortLabel])
        XCTAssertEqual(argument.label, longLabel)
    }

    func testThatItDoesAddsDashesToFlagLabels() {
        
        // given
        let shortLabel = "n"
        let longLabel = "number"
        
        // when
        let argument = FlagArgument(longLabel, shortLabel: shortLabel)
        
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
        let argument = FlagArgument(longLabel)
        
        // then
        XCTAssertEqual(argument.compactLabel, "--number")
    }
 
    func testThatShortLabelCanNotBeLongFlagForOptional() {
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
    
    func testThatShortLabelCanNotBeLongFlagForFlag() {
        // when
        do {
            _ = try FlagArgument(label: "--number", shortLabel: "--number")
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

extension CommandLineArgumentTests {

    func testExpectedFlagDescription() {
        do {
            let sut = FlagArgument("--boo", shortLabel: "-b", help: "help help")
            XCTAssertEqual(sut.description, "--boo, -b                     help help")
        }
        do {
            let sut = FlagArgument("--boo")
            XCTAssertEqual(sut.description, "--boo")
        }
    }
    
    func testExpectedOptionaDescription() {
        
        do {
            let sut = OptionalArgument<Int>("--boo", shortLabel: "-b", help: "help help")
            XCTAssertEqual(sut.description, "--boo, -b BOO<Int>            help help")
        }
        do {
            let sut = OptionalArgument<Int>("--boo")
            XCTAssertEqual(sut.description, "--boo BOO<Int>")
        }
    }

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
    
    func testDescriptionWithNameLongerThanPadding() {
        
        // given
        let label = "--a1234567890123456789012345678901234567890"
        let help = "foo"
        let sut = FlagArgument(label, help: help)
        let expected = "\(label) \(help)"
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, expected)
    }
    
    func testDescriptionWithOptionalLongerThanPadding() {
        
        // given
        let label = "--foooooooooooooooooooooooooooooooooooo"
        let help = "foo"
        let sut = OptionalArgument<Int>(label, help: help)
        let expected = "\(label) \(label.placeholderArgumentString())<Int> \(help)"
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, expected)
    }
}

// MARK: - Parsing

extension CommandLineArgumentTests {
    
    func testThatItReturnsTheValueWhenParsingAValidInt() {
        
        // given
        let sut = PositionalArgument<Int>("foo")
        
        // when
        let parsed = sut.parseValue("34") as? Int
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, 34)
        }
    }
    
    func testThatItReturnsNilWhenParsingAnInvalidInt() {
        
        // given
        let sut = PositionalArgument<Int>("foo")
        
        // when
        let parsed = sut.parseValue("34.2")
        
        // then
        XCTAssertNil(parsed)
    }
    
    func testThatItReturnsTheValueWhenParsingAString() {
        
        // given
        let sut = PositionalArgument<String>("foo")
        
        // when
        let parsed = sut.parseValue("34a") as? String
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, "34a")
        }
    }
    
    func testThatItReturnsTheValueWhenParsingAValidDouble() {
        
        // given
        let sut = PositionalArgument<Double>("foo")
        
        // when
        let parsed = sut.parseValue("34.2") as? Double
        
        // then
        XCTAssertNotNil(parsed)
        if let parsed = parsed {
            XCTAssertEqual(parsed, 34.2)
        }
    }
    
    func testThatItReturnsNilWhenParsingAnInvalidDouble() {
        
        // given
        let sut = PositionalArgument<Double>("foo")
        
        // when
        let parsed = sut.parseValue("34.2a")
        
        // then
        XCTAssertNil(parsed)
    }
    
    func testThatItReturnsTheValueWhenParsingAValidTrueBool() {
        
        // given
        let sut = PositionalArgument<Bool>("foo")
        
        for value in ["TRUE","true","1"] {
            // when
            let parsed = sut.parseValue(value) as? Bool
            
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
            let parsed = sut.parseValue(value) as? Bool
            
            // then
            XCTAssertNotNil(parsed)
            if let parsed = parsed {
                XCTAssertFalse(parsed)
            }
        }
    }
    
    func testThatItReturnsNilWhenParsingAnInvalidBool() {
        
        // given
        let sut = PositionalArgument<Bool>("foo")
        
        // when
        let parsed = sut.parseValue("24")
        
        // then
        XCTAssertNil(parsed)
    }
}

// MARK: - Types

extension CommandLineArgumentTests {

    func testThatTheExpectedTypesMatches() {
        XCTAssertTrue(PositionalArgument<Int>("foo").expectedType == Int.self)
        XCTAssertTrue(PositionalArgument<Bool>("foo").expectedType == Bool.self)
        XCTAssertTrue(OptionalArgument<String>("--foo").expectedType == String.self)
    }
}

// MARK: - Help

extension CommandLineArgumentTests {
    
    func testThatHelpArgumentHasDefaultLabelAndHelpText() {
        
        //when
        let sut = HelpArgument()
        
        // then
        XCTAssertEqual(sut.label, "--help")
        XCTAssertEqual(sut.shortLabel, "-h")
        XCTAssertEqual(sut.help, "show this help message and exit")
    }
}
