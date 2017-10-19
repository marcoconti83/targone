//
//  ParsingErrors.swift
//  Targone
//
//  Created by Marco Conti on 28/12/15.
//  Copyright © 2015 Marco. All rights reserved.
//

import Foundation


/// Error during initialization or when adding an additional argument to a parser
public enum ArgumentParserInitError : Error, CustomStringConvertible {
    
    /// There is more than one argument with the same label
    case moreThanOneArgumentWithSameLabel(label: String)
    
    public var description : String {
        switch(self) {
        case .moreThanOneArgumentWithSameLabel(let label):
            return "more than one argument with the same label '\(label)'"
        }
    }
}


/// Error in parsing argument
public enum CommandLineArgumentParsingError : Error, CustomStringConvertible {
    
    /// The token does not parse to the expected type
    case invalidType(argument: CommandLineArgument, token: String)
    
    /// The value is not in the list of possible choices
    case notInChoices(argument: CommandLineArgument, validChoices: [Any], token: String)
    
    public var description : String {
        switch(self) {
        case .invalidType(let argument, let token):
            return "argument \(argument.label): invalid \(argument.expectedType) value: \(token)"
        case .notInChoices(let argument, let validChoices, let token):
            let choices = validChoices.map { "'\($0)'" }.joined(separator: ", ")
            return "argument \(argument.label): '\(token)' is not in the list of possible choices: \(choices)"
        }
    }
}


/// Error in parsing tokens from command line
public enum ArgumentParsingError : Error, CustomStringConvertible {
    
    /// The previous token requires a parameter, but there is no following valid token
    case parameterExpectedAfterToken(previousToken: String)
    
    /// Unexpected positional arguments. No more positional arguments were expected
    case unexpectedPositionalArgument(token: String)
    
    /// Too few arguments
    case tooFewArguments
    
    public var description : String {
        switch(self) {
        case .parameterExpectedAfterToken(let previousToken):
            return "argument \(previousToken): expected one argument"
        case .unexpectedPositionalArgument(let token):
            return "unrecognized parameter: \(token)"
        case .tooFewArguments:
            return "too few arguments"
        }
    }
}
