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
    fileprivate let summary : String?
    
    /// Name of the currently running script
    fileprivate let scriptName : String
    
    /// Expected arguments
    fileprivate var expectedArguments = [CommandLineArgument]()
    
    /// Help argument
    fileprivate let helpArgument : HelpArgument
    
    /// Help handler, invoked when the parser parses a help command
    fileprivate let helpHandler : (()->())?

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
        processName : String? = nil,
        helpArgument : HelpArgument? = nil,
        helpRequestHandler : (()->())? = nil
        ) throws {
            let processName = processName ?? ArgumentParser.currentScriptName()
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
    fileprivate func validateArguments() throws {
        if let duplicated = self.expectedArguments.firstDuplicatedLabel() {
            throw ArgumentParserInitError.moreThanOneArgumentWithSameLabel(label: duplicated)
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
    public mutating func addArgument(_ argumentDefinition: CommandLineArgument) {
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
            case .flag:
                return true
            case .optional:
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
            case .positional:
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
        func outputArguments(_ styles : [ArgumentStyle], label: String) {
            let filteredArguments = ([self.helpArgument] + expectedArguments).filter { styles.contains($0.style) }.sorted {$0.label < $1.label}
            if(filteredArguments.count > 0) {
                output += "\n\(label) arguments:"
                filteredArguments.forEach { output += "\n\t\($0)" }
                output += "\n"
            }
        }

        outputArguments([.positional], label: "positional")
        outputArguments([.help, .optional, .flag], label: "optional")
            
        return output
    }
    
    /// Returns a compact description of the arguments, as it is expected to be displayed in the usage string
    fileprivate static func usageArgumentDescription(_ arguments: [CommandLineArgument]) -> String{
        return arguments.reduce("", {
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
        
        return [usage, flagsOutput, positionalOutput].filter { $0.characters.count > 0 } .joined(separator: " ")
    }
}

// MARK: - Process arguments

extension ArgumentParser {
    
    /// Returns the name of the script currently run by command line
    private static func currentScriptName() -> String {
        guard let scriptPath = CommandLine.arguments.first else { return "" }
        let scriptURL = URL(fileURLWithPath: scriptPath)
        return scriptURL.lastPathComponent
    }
    
    /// Returns the current process arguments, starting from the second one (i.e. excludes the script name)
    private static func processArguments() -> [String] {
        let size = CommandLine.arguments.count
        return Array(CommandLine.arguments[1..<size])
    }
}

// MARK: - Parsing

extension ArgumentParser {
    
    public typealias ParsingErrorHandler = (_ error: Error)->()

    /// Prints compact usage and exits with status 1
    fileprivate func printUsageAndExit(_ error: Error) -> Never   {
        print(self.shortDescription)
        print("\(self.scriptName): error: \(error)")
        exit(1)
    }
    
    /// Prints usage and exits with status 0
    fileprivate func printHelpAndExit() -> Never  {
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
        _ commandLineTokens: [String]? = nil,
        parsingErrorHandler : ParsingErrorHandler? = nil
    ) -> ParsingResult {

        let commandLineTokens = commandLineTokens ?? ArgumentParser.processArguments()
        // is the first parameter the help parameter?
        if let firstToken = commandLineTokens.first , self.helpArgument.allLabels.contains(firstToken) {
            if let helpHandler = self.helpHandler {
                helpHandler()
            } else {
                self.printHelpAndExit()
            }
            return ParsingResult(labelsToValues: [:])
        }
        
        // should I use default handlers?
        let errorHandler = parsingErrorHandler != nil ? parsingErrorHandler! : { self.printUsageAndExit($0) }
        
        // actual parsing of parameters
        do {
            let parsedStatus = try ParsingStatus(expectedArguments: self.expectedArguments, tokensToParse: commandLineTokens)
            return ParsingResult(labelsToValues: parsedStatus.parsedArguments)
        } catch let err as ArgumentParsingError {
            errorHandler(err)
            return ParsingResult(labelsToValues: [:])
        } catch let err as CommandLineArgumentParsingError {
            errorHandler(err)
            return ParsingResult(labelsToValues: [:])
        } catch {
            ErrorReporting.die(error)
        }
    }
}
