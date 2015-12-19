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


import Foundation

/**
 
A parser of command line arguments.
 
The intended uses is to initialize with the expected arguments, or later add the arguments with `addArgument`, and
 call `parse` to perform the parsing and retrieve the parsed values.
 
 In case the parsing fail, the error is reported and, unless a custom error handler is specified, this will cause
 the script to print out the usage string and abort execution

 */
public struct ArgumentParser {
    
    /// A summary of the script (or part of script) associated with the parser
    private let summary : String?
    
    /// Name of the currently running script
    private let scriptName : String
    
    /// Expected arguments
    private var expectedArguments = [CommandLineArgument]()
    
    /// Help argument
    private let helpArgument : HelpArgument
    
    /// Help handler, invoked when the parser parses a help command
    private let helpHandler : (()->())?

}

/// Error during initialization or when adding an additional argument to a parser
public enum ArgumentParserInitError : ErrorType {
    
    /// There is more than one argument with the same label
    case MoreThanOneArgumentWithSameLabel(label: String)
}

extension Array where Element: CommandLineArgument {
    
    /// Returns any duplicated label
    func firstDuplicatedLabel() -> String? {
        
        var labelsSoFar = Set<String>()
        for arg in self {
            for label in arg.allLabels {
                if labelsSoFar.contains(label) {
                    return label
                }
                labelsSoFar.insert(label)
            }
        }
        return nil
    }
}

extension ArgumentParser {
    
    /**
     Returns an argument parser ready to parse arguments
     
     - parameter arguments: list of parameters to expect on the command line
     - parameter summary: a summary of the script functionalities
     - parameter processName: the script name. If omitted, will pick the name of the currently executing script
     - parameter helpArgument: the argument to be used to display help. If omitted, will use a standard argument with flags "--help" and "-h"
     - parameter helpRequestHandler: callback invoked in case the help argument is found in the first position
     
     - throws: `ArgumentParserInitError.MoreThanOneArgumentWithSameLabel` if more than one argument shares the same flag.
     
     */
    public init(
        arguments : [CommandLineArgument],
        summary: String? = nil,
        processName : String = ArgumentParser.currentScriptName(),
        helpArgument : HelpArgument? = nil,
        helpRequestHandler : (()->())? = nil
        ) throws {
            self.summary = summary
            self.scriptName = processName
            self.expectedArguments = arguments
            self.helpArgument = helpArgument ?? (HelpArgument())
            self.helpHandler = helpRequestHandler
            
            try self.validateArguments()
        }
    
    /**
     Returns an argument parser ready to parse arguments. 
     This is a simplified, error-free version of the other `init`.
     It will assert if more than one argument shares the same flag.
     
     - parameter arguments: list of parameters to expect on the command line
     - parameter summary: a summary of the script functionalities
     - parameter helpArgument: the argument to be used to display help. If omitted, will use a standard argument with flags "--help" and "-h"
     
     
     */
    public init(
        _ arguments : CommandLineArgument...,
        summary: String? = nil,
        help : HelpArgument? = nil
        ) {
            do {
                try self.init(arguments: arguments, summary: summary, processName: ArgumentParser.currentScriptName(), helpArgument: help, helpRequestHandler: nil)
            } catch let error as Any {
                ErrorReporting.die(error)
            }
    }
}

// MARK: - Arguments

extension ArgumentParser {
    
    /**
    Checks that the given arguments are a valid combination

    - throws: throws throws `ArgumentParserInitError.MoreThanOneArgumentWithSameLabel` if there is more than one argument with the same label
    */
    private func validateArguments() throws {
        if let duplicated = self.expectedArguments.firstDuplicatedLabel() {
            throw ArgumentParserInitError.MoreThanOneArgumentWithSameLabel(label: duplicated)
        }
    }
    
    /**

    Adds an argument to the list of arguments expected by the parser. 

    - parameters argument: the argument to add to the parser

    - throws: throws throws `ArgumentParserInitError.MoreThanOneArgumentWithSameLabel` if there is more than one argument with the same label

    */
    
    public mutating func addArgument(argument argumentDefinition: CommandLineArgument) throws {
        self.expectedArguments.append(argumentDefinition)
        try self.validateArguments()
    }
    
    /// Adds an argument to the list of arguments expected by the parser. This is the arror-
    public mutating func addArgument(argumentDefinition: CommandLineArgument) {
        self.expectedArguments.append(argumentDefinition)
        do {
            try self.validateArguments()
        } catch let error as Any {
            ErrorReporting.die(error)
        }
    }
    
    /// Returns only the arguments of flag and optional type
    var flagAndOptionalArguments : [CommandLineArgument] {
        return self.expectedArguments.filter {
            switch($0.style) {
            case .Flag:
                return true
            case .Optional:
                return true
            default:
                return false
            }
        }
    }
    
    /// Returns only the arguments of positional type
    var positionalArguments : [CommandLineArgument] {
        return self.expectedArguments.filter {
            switch($0.style) {
            case .Positional:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Usage and description

extension ArgumentParser : CustomStringConvertible {
    
    /// Returns a string with the usage associated with this parser
    public var description : String {
        
        var output = self.shortDescription + "\n"
        
        if let summary = self.summary {
            output += "\n" + summary + "\n"
        }
        
        /// Outputs the argument list
        func outputArguments(styles : [ArgumentStyle], label: String) {
            let filteredArguments = ([self.helpArgument] + expectedArguments).filter { styles.contains($0.style) }.sort {$0.label < $1.label}
            if(filteredArguments.count > 0) {
                output += "\n\(label) arguments:"
                filteredArguments.forEach { output += "\n\t\($0)" }
                output += "\n"
            }
        }

        outputArguments([.Positional], label: "positional")
        outputArguments([.Help, .Optional, .Flag], label: "optional")
            
        return output
    }
    
    /// Returns a compact description of the arguments, as it is expected to be displayed in the usage string
    private static func usageArgumentDescription(arguments: [CommandLineArgument]) -> String{
        return arguments.reduce("", combine: {
            var output = $0.characters.count > 0 ? " " : ""
            let label = $1.compactLabelWithExpectedValue
            if $1.isOptional {
                output += "[\(label)]"
            }
            else {
                output += label
            }
            return $0 + output
        })
    }
    
    /// Returns a short description of the usage
    public var shortDescription : String {
        
        let usage = "usage: \(self.scriptName)"
        
        let flagsOutput = ArgumentParser.usageArgumentDescription([self.helpArgument] + self.flagAndOptionalArguments)
        let positionalOutput = ArgumentParser.usageArgumentDescription(self.positionalArguments)
        
        return [usage, flagsOutput, positionalOutput].filter { $0.characters.count > 0 } .joinWithSeparator(" ")
    }
}

// MARK: - Process arguments

extension ArgumentParser {
    
    /// Returns the name of the script currently run by command line
    private static func currentScriptName() -> String {
        guard let scriptPath = Process.arguments.first else { return "" }
        let scriptURL = NSURL(fileURLWithPath: scriptPath)
        return scriptURL.lastPathComponent ?? ""
    }
    
    /// Returns the current process arguments, starting from the second one (i.e. excludes the script name)
    private static func processArguments() -> [String] {
        let size = Process.arguments.count
        return Array(Process.arguments[1..<size])
    }
}

// MARK: - Parsing

/// Error in parsing tokens from command line
public enum ArgumentParsingError : ErrorType, CustomStringConvertible {
    
    /// The previous token requires a parameter, but there is no following valid token
    case ParameterExpectedAfterToken(previousToken: String)
    
    /// Unexpected positional arguments. No more positional arguments were expected
    case UnexpectedPositionalArgument(token: String)
    
    /// The token could not be parsed as an argument of the given type
    case InvalidArgumentType(expectedType: Any.Type, label: String, token: String)
    
    /// Too few arguments
    case TooFewArguments
    
    public var description : String {
        switch(self) {
        case .ParameterExpectedAfterToken(let previousToken):
            return "argument \(previousToken): expected one argument"
        case .UnexpectedPositionalArgument(let token):
            return "unrecognized parameter: \(token)"
        case .InvalidArgumentType(let expectedType, let label, let token):
            return "argument \(label): invalid \(expectedType) value: \(token)"
        case .TooFewArguments:
            return "too few arguments"
        }
    }
}

extension Array where Element : CommandLineArgument {
    
    /// Filter arguments by type
    private func filterByType(type: ArgumentStyle) -> [CommandLineArgument] {
        return self.filter { $0.style == type }
    }
}

extension ArgumentParser {
    
    public typealias ParsingErrorHandler = (error: ArgumentParsingError)->()
    
    /// Prints compact usage and exits with status 1
    @noreturn private func printUsageAndExit(error: ArgumentParsingError)  {
        print(self.shortDescription)
        print("\(self.scriptName): error: \(error)")
        exit(1)
    }
    
    /// Prints usage and exits with status 0
    @noreturn private func printHelpAndExit() {
        print(self.description)
        exit(0)
    }
    
    /** 
     Parses the command line arguments according to the expected arguments
     
     - parameter commandLineTokens: the tokens to parse. If not specified, will pick the current process command line arguments minus the first one
     - parameter parsingErrorHandler: callback invoked when a parsing error occurs. If not specified, will by default print usage and exit with status 1
     
     - returns: the result of the parsing
     */
    public func parse(
        commandLineTokens: [String] = ArgumentParser.processArguments(),
        parsingErrorHandler : ParsingErrorHandler? = nil
    ) -> ParsingResult {

        // is the first parameter the help parameter?
        if let firstToken = commandLineTokens.first where self.helpArgument.allLabels.contains(firstToken) {
            if let helpHandler = self.helpHandler {
                helpHandler()
            } else {
                self.printHelpAndExit()
            }
            return ParsingResult(labelsToValues: [:])
        }
        
        // should I use default handlers?
        let errorHandler = parsingErrorHandler != nil ? parsingErrorHandler! : { self.printUsageAndExit($0) }
        
        // create a cache for fast lookup of flag/optional by label
        var flagsLabelsToArgumentsCache : [String : CommandLineArgument] = [:]
        self.expectedArguments.filter { $0.style.hasFlagLikeName()}.forEach { arg in arg.allLabels.forEach {flagsLabelsToArgumentsCache[$0] = arg} }
        
        // actual parsing of parameters
        do {
            return try ArgumentParser.parse(commandLineTokens,
                flagLookupCache: flagsLabelsToArgumentsCache,
                expectedArguments : self.expectedArguments)
        } catch let err as ArgumentParsingError {
            errorHandler(err)
            return ParsingResult(labelsToValues: [:])
        } catch {
            ErrorReporting.die(error)
        }
    }
    
    /**

     Parses the given tokens
     
     - parameter tokens: list of tokens to parse
     - parameter flagLookupCache: label to argument map
     - parameter expectedArguments: the expected arguments
     
     */
    private static func parse(
            tokens: [String],
            flagLookupCache: [String : CommandLineArgument],
            expectedArguments : [CommandLineArgument]
    ) throws -> ParsingResult {
        
        var generator = tokens.generate()
        var nextToken = generator.next()
        var parsedArguments : [String : Any] = [:]
        
        var flagsLeft = Set(expectedArguments.filterByType(.Flag))
        var positionalsLeft = expectedArguments.filterByType(.Positional)
        var optionalsLeft = Set(expectedArguments.filterByType(.Optional))
        
        while (nextToken != nil) {
            guard let token = nextToken else { break }
            defer { nextToken = generator.next() }
            
            // what kind of argument?
            if let argument = flagLookupCache[token] {
                switch(argument.style) {
                case .Optional:
                    optionalsLeft.remove(argument)
                case .Flag:
                    flagsLeft.remove(argument)
                default:
                    ErrorReporting.die("Was not expecting this type of argument: \(argument.style)")
                }
                parsedArguments[argument.label] = try self.parseFlagStyleArgument(argument) { generator.next() }
            }
            else {
                // positional
                guard let positional = positionalsLeft.first else { throw ArgumentParsingError.UnexpectedPositionalArgument(token: token) }
                guard let parsedValue = positional.parseValue(token) else { throw ArgumentParsingError.InvalidArgumentType(expectedType: positional.expectedType, label: positional.label, token: token) }
                
                positional.allLabels.forEach { parsedArguments[$0] = parsedValue }
                positionalsLeft.removeFirst()
            }
        }
        
        // are there still some argument? then it's an error
        if positionalsLeft.count > 0 {
            throw ArgumentParsingError.TooFewArguments
        }
        
        // are there still some flag arguments? then they are false
        flagsLeft.forEach { $0.allLabels.forEach { parsedArguments[$0] = false } }
        
        // are there still some optional arguments? then take the default, if any
        optionalsLeft.forEach {
            if let value = $0.defaultValue {
                $0.allLabels.forEach { parsedArguments[$0] = value }
            }
        }
        
        return ParsingResult(labelsToValues: parsedArguments)
    }
    
    /// Attempts to parse a flag style argument and returns the value
    private static func parseFlagStyleArgument(argument: CommandLineArgument, nextArgumentGenerator: ()->String?)  throws -> Any? {
        if argument.style.requiresAdditionalValue() {
            // optional
            guard let followingToken = nextArgumentGenerator() where !followingToken.isFlagStyle()
                else { throw ArgumentParsingError.ParameterExpectedAfterToken(previousToken: argument.label) }
            return argument.parseValue(followingToken)
        } else {
            // flag
            return true
        }
    }
}
