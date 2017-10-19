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

class HelpArgumentTests: XCTestCase {
    
}

// MARK: - Label

extension HelpArgumentTests {

    func testThatItDoesNotRemoveDashesFromLabels() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = try! HelpArgument(label: longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, [longLabel, shortLabel])
        XCTAssertEqual(argument.label, longLabel)
    }
    
    func testThatItDoesAddDashesToLabels() {
        
        // given
        let shortLabel = "n"
        let longLabel = "number"
        
        // when
        let argument = try! HelpArgument(label: longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.allLabels, ["--number","-n"])
        XCTAssertEqual(argument.label, "--number")
    }
    
    func testThatItUsesShortLabelAsCompactLabel() {
        
        // given
        let shortLabel = "-n"
        let longLabel = "--number"
        
        // when
        let argument = try! HelpArgument(label: longLabel, shortLabel: shortLabel)
        
        // then
        XCTAssertEqual(argument.compactLabel, "-n")
    }
    
    func testThatItUseLabelAsCompactLabelIfThereIsNoShortLabel() {
        
        // given
        let longLabel = "--aiuto"
        
        // when
        let argument = try! HelpArgument(label: longLabel)
        
        // then
        XCTAssertEqual(argument.compactLabel, "--aiuto")
    }
    
    func testThatShortLabelCanNotBeLongFlag() {
        // when
        do {
            _ = try HelpArgument(label: "--number", shortLabel: "--number")
            XCTFail("Did not throw")
        } catch ArgumentInitError.shortLabelCanNotBeLongFlag{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatLabelCanBeShortFlag() {
        // when
        do {
            _ = try HelpArgument(label: "-n")
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnInvalidLabelThrows() {
        
        // when
        do {
            _ = try HelpArgument(label: "-n  ds")
            XCTFail("Did not throw")
        } catch ArgumentInitError.invalidLabel{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatAnInvalidShortLabelThrows() {
        
        // when
        do {
            _ = try HelpArgument(label: "--num", shortLabel: "-n s")
            XCTFail("Did not throw")
        } catch ArgumentInitError.invalidLabel{
            // pass
        } catch let error as Any {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThatItReturnsAllLabelsWhenBothAreSet() {
        
        // given
        let sut = try! HelpArgument(label: "--aiuto", shortLabel: "-a")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["--aiuto","-a"]))
    }
    
    func testThatItReturnsAllLabelsWhenOneIsSet() {
        
        // given
        let sut = try! HelpArgument(label: "--aiuto")
        
        // then
        XCTAssertEqual(sut.allLabels, Set(["--aiuto"]))
    }
    
    func testThatHashOfCommandWithoutShortLabelIsDifferentThanCommandWithShortLabel() {
        
        // given
        let arg1 = try! HelpArgument(label: "aiuto")
        let arg2 = try! HelpArgument(label: "aiuto", shortLabel: "a")
        
        // then
        XCTAssertNotEqual(arg1.hashValue, arg2.hashValue)
    }
}

// MARK: - Description

extension HelpArgumentTests {
    
    func testThatHelpArgumentHasDefaultLabelAndHelpText() {
        
        //when
        let sut = HelpArgument()
        
        // then
        XCTAssertEqual(sut.label, "--help")
        XCTAssertEqual(sut.shortLabel, "-h")
        XCTAssertEqual(sut.help, "show this help message and exit")
    }
    
}
