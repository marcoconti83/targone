//
//  ParsingErrorsTests.swift
//  Targone
//
//  Created by Marco Conti on 28/12/15.
//  Copyright © 2015 Marco. All rights reserved.
//

import Foundation


import XCTest
@testable import Targone

class ParsingErrorsTests: XCTestCase {

}


// MARK: - ArgumentParsingErrors

extension ParsingErrorsTests {
    
    func testDescriptionOfParameterExpectedAfterTokenError() {
        
        // given
        let sut = ArgumentParsingError.ParameterExpectedAfterToken(previousToken: "foo")
        
        // when
        let output = "\(sut)"
        
        // then
        let expected = "argument foo: expected one argument"
        XCTAssertEqual(expected, output)
    }
    
    func testDescriptionOfInvalidArgumentTypeError() {
        
        // given
        let argument = OptionalArgument<Int>("boo")
        let sut = CommandLineArgumentParsingError.InvalidType(argument: argument, token: "bar")
        
        // when
        let output = "\(sut)"
        
        // then
        let expected = "argument --boo: invalid Int value: bar"
        XCTAssertEqual(expected, output)
    }
    
    func testDescriptionOfUnexpectedPositionalArgumentError() {
        
        // given
        let sut = ArgumentParsingError.UnexpectedPositionalArgument(token: "foo")
        
        // when
        let output = "\(sut)"
        
        // then
        let expected = "unrecognized parameter: foo"
        XCTAssertEqual(expected, output)
    }
    
    func testDescriptionOfTooFewArgumentsError() {
        
        // given
        let sut = ArgumentParsingError.TooFewArguments
        
        // when
        let output = "\(sut)"
        
        // then
        let expected = "too few arguments"
        XCTAssertEqual(expected, output)
    }
}

// MARK: - CommandLineArgumentParsingError

extension ParsingErrorsTests {
    
    func testDescriptionOfInvalidType() {
        
        // given
        let token = "hello!"
        let argument = PositionalArgument<Double>("foo")
        let sut = CommandLineArgumentParsingError.InvalidType(argument: argument, token: token)
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, "argument \(argument.label): invalid \(argument.expectedType) value: \(token)")
    }
    
    func testDescriptionOfNotInChoices() {
        
        // given
        let token = "hello!"
        let choices : [Any] = [1,2,3]
        let argument = PositionalArgument<Double>("foo")
        let sut = CommandLineArgumentParsingError.NotInChoices(argument: argument, validChoices: choices, token: token)
        
        // when
        let description = sut.description
        
        // then
        let choicesDescription = choices.map({ "'\($0)'" }).joinWithSeparator(", ")
        XCTAssertEqual(description, "argument \(argument.label): '\(token)' is not in the list of possible choices: \(choicesDescription)")
        
    }
}

// MARK: - ArgumentParserInitError

extension ParsingErrorsTests {
    
    func testDescriptionOfMoreThanOneArgumentWithSameLabel() {
        
        // given
        let label = "speed"
        let sut = ArgumentParserInitError.MoreThanOneArgumentWithSameLabel(label: label)
        
        // when
        let description = sut.description
        
        // then
        XCTAssertEqual(description, "more than one argument with the same label '\(label)'")
    }
    
}
