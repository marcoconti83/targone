//
//  ParsingErrors.swift
//  Targone
//
//  Created by Marco Conti on 28/12/15.
//  Copyright © 2015 Marco. All rights reserved.
//

import Foundation


/// Error during initialization or when adding an additional argument to a parser
public enum ArgumentParserInitError : ErrorType, CustomStringConvertible {
    
    /// There is more than one argument with the same label
    case MoreThanOneArgumentWithSameLabel(label: String)
    
    public var description : String {
        switch(self) {
        case .MoreThanOneArgumentWithSameLabel(let label):
            return "more than one argument with the same label '\(label)'"
        }
    }
}


/// Error in parsing argument
public enum CommandLineArgumentParsingError : ErrorType, CustomStringConvertible {
    
    /// The token does not parse to the expected type
    case InvalidType(argument: CommandLineArgument, token: String)
    
    /// The value is not in the list of possible choices
    case NotInChoices(argument: CommandLineArgument, validChoices: [Any], token: String)
    
    public var description : String {
        switch(self) {
        case .InvalidType(let argument, let token):
            return "argument \(argument.label): invalid \(argument.expectedType) value: \(token)"
        case .NotInChoices(let argument, let validChoices, let token):
            let choices = validChoices.map { "'\($0)'" }.joinWithSeparator(", ")
            return "argument \(argument.label): '\(token)' is not in the list of possible choices: \(choices)"
        }
    }
}


/// Error in parsing tokens from command line
public enum ArgumentParsingError : ErrorType, CustomStringConvertible {
    
    /// The previous token requires a parameter, but there is no following valid token
    case ParameterExpectedAfterToken(previousToken: String)
    
    /// Unexpected positional arguments. No more positional arguments were expected
    case UnexpectedPositionalArgument(token: String)
    
    /// Too few arguments
    case TooFewArguments
    
    public var description : String {
        switch(self) {
        case .ParameterExpectedAfterToken(let previousToken):
            return "argument \(previousToken): expected one argument"
        case .UnexpectedPositionalArgument(let token):
            return "unrecognized parameter: \(token)"
        case .TooFewArguments:
            return "too few arguments"
        }
    }
}