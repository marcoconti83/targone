//
//  ParsingStatus.swift
//  Targone
//
//  Created by Marco Conti on 28/12/15.
//  Copyright © 2015 Marco. All rights reserved.
//

import Foundation

extension Array where Element : CommandLineArgument {
    
    /// Filter arguments by type
    fileprivate func filterByType(_ type: ArgumentStyle) -> [CommandLineArgument] {
        return self.filter { $0.style == type }
    }
}

/// Status of the parsing of arguments
/// e.g. what was parsed so far, what is still missing, ...
struct ParsingStatus {
    
    /// look up for optionals labels ("--foo")
    fileprivate let argumentLookupByOptionalLabel : [String : CommandLineArgument]
    
    /// arguments still to parse, by type of flag
    fileprivate var nonPositionalArgumentsStillToParse = [ArgumentStyle : Set<CommandLineArgument>]()
    
    /// positional arguments still to parse
    fileprivate var positionalArgumentsStillToParse : [CommandLineArgument]
    
    /// arguments parsed so far
    var parsedArguments = [String : Any]()
    
    /// next token generator
    fileprivate var generator : IndexingIterator<[String]>
    
    init(expectedArguments: [CommandLineArgument], tokensToParse: [String]) throws {
        var lookupByOptionalLabel : [String : CommandLineArgument] = [:]
        expectedArguments.filter { $0.style.hasFlagLikeName()}.forEach { arg in arg.allLabels.forEach {lookupByOptionalLabel[$0] = arg} }
        self.argumentLookupByOptionalLabel = lookupByOptionalLabel
        
        for argumentType in [ArgumentStyle.flag, ArgumentStyle.optional] {
            nonPositionalArgumentsStillToParse[argumentType] = Set(expectedArguments.filterByType(argumentType))
        }
        self.positionalArgumentsStillToParse = expectedArguments.filterByType(.positional)
        self.generator = tokensToParse.makeIterator()
        
        try self.startParsing()
    }
    
    /// Parse the tokens
    fileprivate mutating func startParsing() throws {
        var nextToken = self.generator.next()
        
        while (nextToken != nil) {
            guard let token = nextToken else { break }
            defer { nextToken = self.generator.next() }
            try self.parseToken(token)
        }
        
        // are there still some argument? then it's an error
        if self.positionalArgumentsStillToParse.count > 0 {
            throw ArgumentParsingError.tooFewArguments
        }
        
        // are there still some flag arguments? then they are false
        self.nonPositionalArgumentsStillToParse[.flag]!.forEach { self.setParsedValue(false, argument: $0) }
        
        // are there still some optional arguments? then take the default, if any
        if let remainingArgumentsWithPossibleDefaultValue = self.nonPositionalArgumentsStillToParse[.optional] {
            remainingArgumentsWithPossibleDefaultValue.forEach {
                if let defaultValue = $0.defaultValue, let value = defaultValue {
                    self.setParsedValue(value, argument: $0)
                }
            }
        }
    }
    
    /// Set the parsed value for the argument
    fileprivate mutating func setParsedValue(_ value: Any, argument: CommandLineArgument) {
        argument.allLabels.forEach {
            self.parsedArguments[$0] = value
        }
    }
    
    /// parse a specific token
    fileprivate mutating func parseToken(_ token: String) throws {
        // what kind of argument?
        if let argument = self.argumentLookupByOptionalLabel[token] {
            switch(argument.style) {
            case .optional:
                self.nonPositionalArgumentsStillToParse[argument.style]!.remove(argument)
            case .flag:
                self.nonPositionalArgumentsStillToParse[argument.style]!.remove(argument)
            default:
                ErrorReporting.die("Was not expecting this type of argument: \(argument.style)")
            }
            if let parsed = try self.parseFlagStyleArgument(argument) {
                parsedArguments[argument.label] = parsed
            }
        }
        else {
            // positional
            guard let positional = self.positionalArgumentsStillToParse.first else { throw ArgumentParsingError.unexpectedPositionalArgument(token: token) }
            self.positionalArgumentsStillToParse.removeFirst()
            if let parsedValue = try self.parsePositionalArgument(positional, token: token) {
                positional.allLabels.forEach { parsedArguments[$0] = parsedValue }
            }
        }
    }
    
    /// Attempts to parse a flag style argument and returns the value
    fileprivate mutating func parseFlagStyleArgument(_ argument: CommandLineArgument) throws -> Any? {
        if argument.style.requiresAdditionalValue() {
            // optional
            guard let followingToken = self.generator.next() , !followingToken.isFlagStyle()
                else { throw ArgumentParsingError.parameterExpectedAfterToken(previousToken: argument.label) }
            return try argument.parseValue(followingToken)
        } else {
            // flag
            return true
        }
    }
    
    fileprivate mutating func parsePositionalArgument(_ argument: CommandLineArgument, token: String) throws -> Any? {
        return try argument.parseValue(token)
        
    }
}
