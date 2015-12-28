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

class FlagArgumentTests: XCTestCase {
    
}

// MARK: - Label

extension FlagArgumentTests {
    
    func testThatItDoesNotRemoveDashesFromLabels() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = FlagArgument(longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, [longLabel, shortLabel])
        XCTAssertEqual(argument.label, longLabel)
    }
    
    func testThatItDoesAddDashesToLabels() {
        
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
        let argument = FlagArgument(longLabel, shortLabel: shortLabel)
        
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
    
    func testThatShortLabelCanNotBeLongFlag() {
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
            _ = try FlagArgument(label: "-n")
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnInvalidLabelThrows() {
        
        // when
        do {
            _ = try FlagArgument(label: "-n  ds")
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
            _ = try FlagArgument(label: "--num", shortLabel: "-n s")
            XCTFail("Did not throw")
        } catch ArgumentInitError.InvalidLabel{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatItReturnsAllLabelsWhenBothAreSet() {
        
        // given
        let sut = FlagArgument("--number", shortLabel: "-n")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["--number","-n"]))
    }
    
    func testThatItReturnsAllLabelsWhenOneIsSet() {
        
        // given
        let sut = FlagArgument("--number")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["--number"]))
    }
    
    func testThatHashOfCommandWithoutShortLabelIsDifferentThanCommandWithShortLabel() {
        
        // given
        let arg1 = FlagArgument("foo")
        let arg2 = FlagArgument("foo", shortLabel: "f")
        
        // then
        XCTAssertNotEqual(arg1.hashValue, arg2.hashValue)
    }
}

// MARK: - Description

extension FlagArgumentTests {
    
    func testExpectedDescription() {
        do {
            let sut = FlagArgument("--boo", shortLabel: "-b", help: "help help")
            XCTAssertEqual(sut.description, "--boo, -b                     help help")
        }
        do {
            let sut = FlagArgument("--boo")
            XCTAssertEqual(sut.description, "--boo")
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
}

