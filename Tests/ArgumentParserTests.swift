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

class ArgumentParserTests: XCTestCase {
    
    /// Argument label with description
    private static func argumentDescription(_ label: String, description: String) -> String {
        let Padding = 30
        let needsPadding = label.characters.count < Padding
        let paddedFirstColumn = needsPadding ?
            // TODO: remove NSString
            NSString(string: label).padding(toLength: Padding, withPad: " ", startingAt: 0) as String :
            label + " "
        return "\t" + paddedFirstColumn + description
    }
    
    /// Standard help description
    static let helpArgumentDescription = ArgumentParserTests.argumentDescription("--help, -h", description: "show this help message and exit")
}

// MARK: - Description

extension ArgumentParserTests {
    
    func testThatItGeneratesDescriptionWithNoArguments() {
        
        // given
        let summary = "A test script"
        let name = "Foo.swift"
        let expected = [
            "usage: Foo.swift [-h]",
            "",
            "A test script",
            "",
            "optional arguments:",
            ArgumentParserTests.helpArgumentDescription,
            ""
            ].joined(separator: "\n")
        
        // when
        let sut = try! ArgumentParser(arguments: [], summary: summary, processName: name)
        
        // then
        XCTAssertEqual(sut.description, expected)
    }
    
    func testThatItGeneratesShortDescriptionWithNoArguments() {
        
        // given
        let name = "Foo.swift"
        let expected =
            "usage: Foo.swift [-h]"
        
        // when
        let sut = try! ArgumentParser(arguments: [], summary: "A test", processName: name)
        
        // then
        XCTAssertEqual(sut.shortDescription, expected)
    }
    
    func testThatItGeneratesDescriptionWithPositionalArguments() {
        
        // given
        let summary = "A test script"
        let name = "Foo.swift"
        let positionalArguments = [
            PositionalArgument<String>("source", help: "An input file"),
            PositionalArgument<Int>("count", help: "How many times")
        ]
        
        let expected = [
            "usage: Foo.swift [-h] source count<Int>",
            "",
            "A test script",
            "",
            "positional arguments:",
            ArgumentParserTests.argumentDescription("count<Int>", description: "How many times"),
            ArgumentParserTests.argumentDescription("source", description: "An input file"),
            "",
            "optional arguments:",
            ArgumentParserTests.helpArgumentDescription,
            ""
            ].joined(separator: "\n")
        
        // when
        var sut = try! ArgumentParser(arguments: [], summary: summary, processName: name)
        positionalArguments.forEach { sut.addArgument($0) }
        
        // then
        XCTAssertEqual(sut.description, expected)
    }
    
    func testThatItGeneratesAShortDescriptionWithArguments() {
        
        // given
        let summary = "A test script"
        let name = "Foo.swift"
        let positionalArguments = [
            PositionalArgument<String>("source", help: "An input file"),
            PositionalArgument<Int>("n", help: "Number")
        ]
        
        let expected = "usage: Foo.swift [-h] source n<Int>"
        
        // when
        var sut = try! ArgumentParser(arguments: [], summary: summary, processName: name)
        positionalArguments.forEach { sut.addArgument($0) }
        
        // then
        XCTAssertEqual(sut.shortDescription, expected)
    }
    
    func testThatItGeneratesDescriptionWithOptionalArguments() {
        
        // given
        let summary = "A test script"
        let name = "Foo.swift"
        let optionalArguments = [
            OptionalArgument<String>("--source", help: "An input file"),
            OptionalArgument<Int>("--count", help: "How many times")
        ]
        
        let expected = [
            "usage: Foo.swift [-h] [--source SOURCE] [--count COUNT<Int>]",
            "",
            "A test script",
            "",
            "optional arguments:",
            ArgumentParserTests.argumentDescription("--count COUNT<Int>", description: "How many times"),
            ArgumentParserTests.helpArgumentDescription,
            ArgumentParserTests.argumentDescription("--source SOURCE", description: "An input file"),
            ""
            ].joined(separator: "\n")
        
        // when
        var sut = try! ArgumentParser(arguments: [], summary: summary, processName: name)
        optionalArguments.forEach { sut.addArgument($0) }
        
        // then
        XCTAssertEqual(sut.description, expected)
    }
    
    func testThatItGeneratesDescriptionWithOptionalAndPositionalArguments() {
        
        // given
        let summary = "A test script"
        let name = "Foo.swift"
        let positionalArguments = [
            PositionalArgument<String>("file", help: "A file"),
        ]
        let optionalArguments = [
            OptionalArgument<String>("--source", help: "An input file"),
        ]
        
        let expected = [
            "usage: Foo.swift [-h] [--source SOURCE] file",
            "",
            "A test script",
            "",
            "positional arguments:",
            ArgumentParserTests.argumentDescription("file", description: "A file"),
            "",
            "optional arguments:",
            ArgumentParserTests.helpArgumentDescription,
            ArgumentParserTests.argumentDescription("--source SOURCE", description: "An input file"),
            ""
            ].joined(separator: "\n")
        
        // when
        var sut = try! ArgumentParser(arguments: [], summary: summary, processName: name)
        optionalArguments.forEach { sut.addArgument($0) }
        positionalArguments.forEach { sut.addArgument($0) }
        
        // then
        XCTAssertEqual(sut.description, expected)
    }
}

// MARK: - Parsing errors

extension ArgumentParserTests {
    
    func testThatItThrowsWhenTooFewArguments() {
        
        // given
        let argument1 = PositionalArgument<Int>("foo")
        let argument2 = PositionalArgument<String>("bar")
        let parser = ArgumentParser(argument1, argument2, summary: "Parser")
        
        // when
        _ = parser.parse(["12"]) { error in
            switch(error) {
            case ArgumentParsingError.TooFewArguments:
                break
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenAnOptionalArgumentWithChoicesHasAnInvalidChoice() {
        
        // given
        let value = "12"
        let choices : [Int] = [3,4]
        let argument = OptionalArgument<Int>("foo", choices: choices)
        let parser = ArgumentParser(argument, summary: "Parser")
        
        // when
        _ = parser.parse(["--foo",value]) { error in
            switch(error) {
            case CommandLineArgumentParsingError.NotInChoices(let argument, let validChoices, let token):
                XCTAssertEqual(argument.label, "--foo")
                XCTAssertEqual(validChoices.map { $0 as! Int}, choices)
                XCTAssertEqual(token, value)
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenAPositionalArgumentWithChoicesHasAnInvalidChoice() {
        
        // given
        let value = "12"
        let choices = [3,4]
        let argument = PositionalArgument<Int>("foo", choices: choices)
        let parser = ArgumentParser(argument, summary: "Parser")
        
        // when
        _ = parser.parse([value]) { error in
            switch(error) {
            case CommandLineArgumentParsingError.NotInChoices(let argument, let validChoices, let token):
                XCTAssertEqual(argument.label, "foo")
                XCTAssertEqual(token, value)
                XCTAssertEqual(choices, validChoices.map { $0 as! Int })
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenExpectingParameterAfterTokenButThereAreNoMoreArguments() {
        
        // given
        let argument1 = OptionalArgument<Int>("--foo")
        let parser = ArgumentParser(argument1, summary: "Parser")
        
        // when
        _ = parser.parse(["--foo"]) { error in
            switch(error) {
            case ArgumentParsingError.ParameterExpectedAfterToken(let previousToken):
                XCTAssertEqual(previousToken, "--foo")
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenExpectingParameterAfterTokenButThereIsAnotherFlag() {
        
        // given
        let argument1 = OptionalArgument<Int>("--foo")
        let argument2 = FlagArgument("--bar")
        let parser = ArgumentParser(argument1, argument2, summary: "Parser")
        
        // when
        _ = parser.parse(["--foo","--bar"]) { error in
            switch(error) {
            case ArgumentParsingError.ParameterExpectedAfterToken(let previousToken):
                XCTAssertEqual(previousToken, "--foo")
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenNotExpectingPositionalParameter() {
        
        // given
        let argument1 = FlagArgument("--foo")
        let argument2 = FlagArgument("--bar")
        let parser = ArgumentParser(argument1, argument2, summary: "Parser")
        
        // when
        _ = parser.parse(["--foo","12", "--bar"]) { error in
            switch(error) {
            case ArgumentParsingError.UnexpectedPositionalArgument(let token):
                XCTAssertEqual(token, "12")
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenTheTypeDoesNotMatch() {
        
        // given
        let argument1 = FlagArgument("--foo")
        let argument2 = PositionalArgument<Int>("bar")
        let parser = ArgumentParser(argument1, argument2, summary: "Parser")
        
        // when
        _ = parser.parse(["--foo","12.4"]) { error in
            switch(error) {
            case CommandLineArgumentParsingError.InvalidType(let argument, let token):
                XCTAssertEqual(token, "12.4")
                XCTAssertEqual(argument.label, "--foo")
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
    
    func testThatItThrowsWhenThereAreTooFewArguments() {
        
        // given
        let argument1 = FlagArgument("--foo")
        let argument2 = PositionalArgument<Int>("bar")
        let parser = ArgumentParser(argument1, argument2, summary: "Parser")
        
        // when
        _ = parser.parse(["--foo"]) { error in
            switch(error) {
            case ArgumentParsingError.TooFewArguments:
                break
            default:
                XCTFail("Unexpected error \(error)")
            }
        }
    }
}

// MARK: - Parsing values

extension ArgumentParserTests {
    
    func testThatItParsesFlagArguments() {
        
        // given
        let argument1 = FlagArgument("--foo")
        let argument2 = FlagArgument("--bar")
        let argument3 = FlagArgument("--baz", shortLabel: "-b")
        let parser = ArgumentParser(argument1, argument2, argument3, summary: "Parser")
        
        // when
        let parsed = parser.parse(["-b", "--foo"]) { error in
            XCTFail("Unexpected error \(error)")
        }
        
        // then
        XCTAssertEqual(parsed.boolValue("foo"), Optional<Bool>(true))
        XCTAssertEqual(parsed.boolValue("bar"), Optional<Bool>(false))
        XCTAssertEqual(parsed.boolValue("baz"), Optional<Bool>(true))
    }
    
    func testThatItParsesPositionalArguments() {
        
        // given
        let argument1 = PositionalArgument<String>("foo")
        let argument2 = PositionalArgument<Int>("bar")
        let parser = ArgumentParser(argument1, argument2, summary: "Parser")
        
        // when
        let parsed = parser.parse(["fox","12"]) { error in
            XCTFail("Unexpected error \(error)")
        }
        
        // then
        XCTAssertEqual(parsed.stringValue("foo"), Optional<String>("fox"))
        XCTAssertEqual(parsed.intValue("bar"), Optional<Int>(12))
    }
    
    func testThatItParsesOptionalArguments() {
        
        // given
        let argument1 = OptionalArgument<Int>("--foo")
        let argument2 = OptionalArgument<Int>("--bar")
        let argument3 = OptionalArgument<String>("--max")
        let parser = ArgumentParser(argument1, argument2, argument3, summary: "Parser")
        
        // when
        let parsed = parser.parse(["--foo","12","--max","oh"]) { error in
            XCTFail("Unexpected error \(error)")
        }
        
        // then
        XCTAssertEqual(parsed.intValue("foo"), Optional<Int>(12))
        XCTAssertNil(parsed.intValue("bar"))
        XCTAssertEqual(parsed.stringValue("max"), Optional<String>("oh"))
    }
    
    func testThatItParsesCombinedArgumentTypes() {
        
        // given
        let argument1 = OptionalArgument<Int>("--foo")
        let argument2 = PositionalArgument<Double>("bar")
        let argument3 = OptionalArgument<String>("--max")
        let parser = ArgumentParser(argument1, argument2, argument3, summary: "Parser")
        
        // when
        let parsed = parser.parse(["50.2","--foo","12"]) { error in
            XCTFail("Unexpected error \(error)")
        }
        
        // then
        XCTAssertEqual(parsed.intValue("foo"), Optional<Int>(12))
        XCTAssertEqual(parsed.value("bar") as? Double, Optional<Double>(50.2))
        XCTAssertNil(parsed.stringValue("max"))
    }
    
    func testThatItParsesAnOptionalArgumentWithChoices() {
        
        // given
        let argument = OptionalArgument<Int>("foo", choices: [3,4])
        let parser = ArgumentParser(argument, summary: "Parser")
        
        // when
        let result = parser.parse(["--foo","3"])
        
        // then
        XCTAssertEqual(result.intValue("foo"), 3)
    }
    
    func testThatItParsesAPositionalArgumentWithChoices() {
        
        // given
        let argument = PositionalArgument<Int>("foo", choices: [3,4])
        let parser = ArgumentParser(argument, summary: "Parser")
        
        // when
        let result = parser.parse(["3"])
        
        // then
        XCTAssertEqual(result.intValue("foo"), 3)
    }
}

// MARK: - Help
extension ArgumentParserTests {

    func testThatItCallsStandardShortHelpHandler() {
        
        // given
        let expectation = self.expectation(description: "Help function called")
        let parser = try! ArgumentParser(arguments: [OptionalArgument<Int>("--boo")], helpRequestHandler: {
            expectation.fulfill()
        })
        
        // when
        _ = parser.parse(["-h"])
        
        // then
        self.waitForExpectations(timeout: 0, handler: nil)
        
    }
    
    func testThatItCallsStandardLongHelpHandler() {
        
        // given
        let expectation = self.expectation(description: "Help function called")
        let parser = try! ArgumentParser(arguments: [OptionalArgument<Int>("--boo")], helpRequestHandler: {
            expectation.fulfill()
        })
        
        // when
        _ = parser.parse(["--help"])
        
        // then
        self.waitForExpectations(timeout: 0, handler: nil)
        
    }
    
    func testThatItCallsCustomShortHelpHandler() {
        
        // given
        let expectation = self.expectation(description: "Help function called")
        let parser = try! ArgumentParser(arguments: [OptionalArgument<Int>("--boo")],
            helpArgument: HelpArgument(label: "foo", shortLabel: "f"),
            helpRequestHandler: {
                expectation.fulfill()
            }
        )
        
        // when
        _ = parser.parse(["-f"])
        
        // then
        self.waitForExpectations(timeout: 0, handler: nil)
    }
    
    func testThatItCallsCustomLongHelpHandler() {
        
        // given
        let expectation = self.expectation(description: "Help function called")
        let parser = try! ArgumentParser(arguments: [OptionalArgument<Int>("--boo")],
            helpArgument: HelpArgument(label: "foo", shortLabel: "f"),
            helpRequestHandler: {
                expectation.fulfill()
            }
        )
        
        // when
        _ = parser.parse(["--foo"])
        
        // then
        self.waitForExpectations(timeout: 0, handler: nil)
        
    }
    
}

// MARK: - Errors
extension ArgumentParserTests {

    func testThatItThrowsIfInitializedWithArgumentsWithDuplicatedLabel() {
        
        // given
        let arg1 = FlagArgument("-f")
        let arg2 = OptionalArgument<Int>("--foo", shortLabel: "-f")
        
        // when
        do {
            let _ = try ArgumentParser(arguments: [arg1, arg2])
        } catch ArgumentParserInitError.MoreThanOneArgumentWithSameLabel(let label) {
            XCTAssertEqual(label, "-f")
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItThrowsIfInitializedWithArgumentsWithDuplicatedLabelWithAndWithoutFlagPrefix() {
        
        // given
        let arg1 = FlagArgument("foo")
        let arg2 = OptionalArgument<Int>("--foo", shortLabel: "-f")
        
        // when
        do {
            let _ = try ArgumentParser(arguments: [arg1, arg2])
        } catch ArgumentParserInitError.MoreThanOneArgumentWithSameLabel(let label) {
            XCTAssertEqual(label, "--foo")
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testThatItThrowsIfAddingArgumentsWithDuplicatedLabel() {
        
        // given
        let arg1 = FlagArgument("-f")
        let arg2 = OptionalArgument<Int>("--foo", shortLabel: "-f")
        var parser = ArgumentParser(arg1)
        
        // when
        do {
            try parser.addArgument(argument: arg2)
        } catch ArgumentParserInitError.MoreThanOneArgumentWithSameLabel(let label) {
            XCTAssertEqual(label, "-f")
        } catch {
            XCTFail("Unexpected error")
        }
    }
}

// MARK: - Default values

extension ArgumentParserTests {

    func testThatItReturnsTheDefaultValueForOptionalIfTheValueIsNotSpecified() {
        
        // given
        let arg1 = OptionalArgument<Int>("--foo", shortLabel: "-f", defaultValue: 100)
        let parser = ArgumentParser(arg1)
        
        // when
        let result = parser.parse([])
        
        // then
        XCTAssertEqual(result.value(arg1), 100)
    }
}
