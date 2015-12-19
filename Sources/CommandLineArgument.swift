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

/// Padding used in output for first column
private let OutputFirstColumnPadding = 30


/// Errors in initializing arguments
public enum ArgumentInitError : ErrorType {

    /// Can not specify a flag-like label when the argument is not optional
    case LabelCanNotBeFlagIfArgumentIsPositional
    /// Short label (`-n`) can't be a long flag (`--number`)
    case ShortLabelCanNotBeLongFlag
    /// Invalid label
    case InvalidLabel
}

/**
 
 An argument expected on the command line.
 
 */
public class CommandLineArgument {
    
    /// Style of argument
    let style : ArgumentStyle
    
    /// Argument label
    let label : String
    
    /// The short argument label
    let shortLabel : String?
    
    /**
     Default value for the argument, to be used when no value is given on the command line
     The double optional is used with this meaning:
     
     - 1st optional level: whether the default value was passed in
     the init or not. It will be `nil` if it was not passed.
     
     - 2nd optional level: the value passed as the default
     */
    let defaultValue : Any??
    
    /// The help text
    let help : String?
    
    /// The expected type of this parameter
    let expectedType : InitializableFromString.Type
    
    private init<Type where Type : InitializableFromString>(
        label: String,
        style: ArgumentStyle,
        shortLabel: String? = nil,
        defaultValue : Type?? = nil,
        help : String? = nil
        ) throws
    {
        self.label = label
        self.shortLabel = shortLabel
        self.defaultValue = defaultValue
        self.help = help
        self.style = style
        self.expectedType = Type.self
        
        if self.allLabels.filter({ !$0.isValidArgumentName() }).count > 0 {
            throw ArgumentInitError.InvalidLabel
        }
    
        if let shortLabel = shortLabel where shortLabel.isLongFlagStyle() {
            throw ArgumentInitError.ShortLabelCanNotBeLongFlag
        }
    }
}

// MARK: - Hashable

extension CommandLineArgument : Hashable {
    
    public var hashValue : Int {
        return self.label.hashValue + (self.shortLabel?.hashValue ?? 0)
    }
}

public func ==(lhs: CommandLineArgument, rhs: CommandLineArgument) -> Bool {
    return lhs.expectedType == rhs.expectedType
    && lhs.allLabels == rhs.allLabels
    && lhs.help == rhs.help
    && lhs.style == rhs.style
}

// MARK: - Label

extension CommandLineArgument {
    
    /// Returns either the shorter label or the label (in that order)
    var compactLabel : String {
        return self.shortLabel ?? self.label
    }
    
    /// All possible labels
    var allLabels: Set<String> {
        return Set([self.label, self.shortLabel].flatMap { $0 })
    }
}

// MARK: - Parsing

extension CommandLineArgument {
    
    /// Attempts to parse a value matching the argument.
    /// returns `nil` if it was not possible to parse a valid value
    func parseValue(string: String) -> Any? {
        return self.expectedType.init(initializationString: string)
    }
    
    /// Whether this argument is optional
    var isOptional : Bool {
        switch(self.style) {
        case .Positional:
            return false
        default:
            return true
        }
    }
}

// MARK: - String representation

extension CommandLineArgument : CustomStringConvertible {

    /// Returns the type specification needed for the given type
    private func placeholderArgumentDescription() -> String {
        if self.style.requiresAdditionalValue() {
            return " "+self.label.placeholderArgumentString()
        }
        return ""
    }
    
    /// Returns the type specifications according to the expected type (none for String, <Type> for any other)
    private func typeSpecificationDescription() -> String {
        if self.expectedType == String.self || !self.style.requiresValue() {
            return ""
        }
        return "<\(self.expectedType)>"
    }

    /// Returns the argument and the expected value placeholder, if any
    var compactLabelWithExpectedValue : String {
        return self.compactLabel + self.placeholderArgumentDescription() + self.typeSpecificationDescription()
    }
    
    public var description : String {
        
        let placeholderArgument = self.placeholderArgumentDescription() + self.typeSpecificationDescription()
        let firstColumn = "\(label)" +
            (self.shortLabel != nil ? ", "+shortLabel! : "" ) +
            placeholderArgument
        let secondColumn = self.help
        
        let needsPadding = firstColumn.characters.count < OutputFirstColumnPadding
        let paddedFirstColumn = needsPadding ?
            firstColumn.stringByPaddingToLength(OutputFirstColumnPadding, withString: " ", startingAtIndex: 0) :
            firstColumn + " "
        
        if let secondColumn = secondColumn {
            return paddedFirstColumn + secondColumn
        }
        else {
            return firstColumn
        }
    }
}


// MARK: - Flag argument

/**
 A flag-like command line argument
 
A flag argument:
- does not require any additional value
- has a labe that starts with "--" or "-"
- is optional
- parses to a `Bool` value

 e.g. the `quiet` argument in

     do.swift --quiet`
 
 */

public class FlagArgument : CommandLineArgument {
    
    /**
     Returns a flag argument.
     
     - parameter label: the label. If the flag prefix ("--") is missing, will automatically add it
     - parameter shortLabel: the short version of the label (e.g. "-f"). If the short flag prefix is missing, will automatically add it
     - parameter help: the help text used to describe the parameter
     
     - throws: One of `ArgumentInitError` in case there is an error in the labels that are used
    */
    public init(
        label: String,
        shortLabel : String? = nil,
        help : String? = nil
        ) throws
    {
        try super.init(
            label: label.addLongFlagPrefix(),
            style: ArgumentStyle.Flag,
            shortLabel: shortLabel?.addShortFlagPrefix(),
            help : help,
            defaultValue : false
        )
    }
    
    /**
     Returns a flag argument. This is the error-free version of the other `init`. It will assert in case of error.
     
     - parameter label: the label. If the flag prefix ("--") is missing, will automatically add it
     - parameter shortLabel: the short version of the label (e.g. "-f"). If the short flag prefix is missing, will automatically add it
     - parameter help: the help text used to describe the parameter
     
     */
    public convenience init(
        _ label: String,
        shortLabel : String? = nil,
        help : String? = nil
        ) {
            do {
                try self.init(label: label, shortLabel: shortLabel, help: help)
            } catch let error as Any {
                ErrorReporting.die(error)
            }
    }
}

// MARK: - Optional argument

/**
 An optional command line argument

An optional argument:
- requires a following additional value
- has a label that starts with "--" or "-"
- is optional

 e.g. the `speed` argument in 

     do.swift --speed 10
 
 */
public class OptionalArgument<T where T: InitializableFromString> : CommandLineArgument {
    
    /**
     Returns an optional argument.
     
     - parameter label: the label. If the flag prefix ("--") is missing, will automatically add it
     - parameter shortLabel: the short version of the label (e.g. "-f"). If the short flag prefix is missing, will automatically add it
     - parameter help: the help text used to describe the parameter
     - parameter defaultValue: if the argument is not present on the command line, it will be set to the given default value. If no default value is given,
     it will be set to `nil`
     
     - throws: One of `ArgumentInitError` in case there is an error in the labels that are used
     */
    public init(
        label: String,
        shortLabel : String? = nil,
        defaultValue : T? = nil,
        help : String? = nil
        ) throws
    {
        try super.init(
            label: label.addLongFlagPrefix(),
            style: ArgumentStyle.Optional,
            shortLabel: shortLabel?.addShortFlagPrefix(),
            defaultValue : defaultValue,
            help : help
        )
    }
    
    /**
     Returns an optional argument. This is the error-free version of the other `init`. It will assert in case of error.
     
     - parameter label: the label. If the flag prefix ("--") is missing, will automatically add it
     - parameter shortLabel: the short version of the label (e.g. "-f"). If the short flag prefix is missing, will automatically add it
     - parameter help: the help text used to describe the parameter
     - parameter defaultValue: if the argument is not present on the command line, it will be set to the given default value. If no default value is given,
     it will be set to `nil`
    */
    public convenience init(
        _ label: String,
        shortLabel : String? = nil,
        defaultValue : T? = nil,
        help : String? = nil
        ) {
            do {
                try self.init(label: label, shortLabel: shortLabel, defaultValue: defaultValue, help: help)
            } catch let error as Any {
                ErrorReporting.die(error)
            }
    }
}

// MARK: - Positional argument

/**
 A positional command line argument

A positional argument:
- is parsed based on the order (the first positional argument will match the first non-argument token in the command line arguments)
- is not optional
- has a label that does not start with "--" or "-"


 e.g. the `file` argument in

     do.swift file

 */
public class PositionalArgument<T where T: InitializableFromString> : CommandLineArgument {
    
    /**
     Returns a positional argument.
     
     - parameter label: the label. It should not start with "-" or "--" or it will throw an error
     - parameter help: the help text used to describe the parameter
     - parameter defaultValue: if the argument is not present on the command line, it will be set to the given default value. If no default value is given, there will be a parsing error
     
     - throws: One of `ArgumentInitError` in case there is an error in the label that is used
     */
    public init(
        label: String,
        defaultValue : T? = nil,
        help : String? = nil
        ) throws
    {
        try super.init(
            label: label.removeFlagPrefix(),
            style: .Positional,
            defaultValue: defaultValue,
            help: help
        )
        
        if label.isFlagStyle() {
            throw ArgumentInitError.LabelCanNotBeFlagIfArgumentIsPositional
        }
    }
    
    /**
     Returns a positional argument. This is the error-free version of the other `init:`. It will assert in case of error.
     
     - parameter label: the label. It should not start with "-" or "--" or it will throw an error
     - parameter help: the help text used to describe the parameter
     - parameter defaultValue: if the argument is not present on the command line, it will be set to the given default value. If no default value is given, there will be a parsing error
     
     */
    public convenience init(
        _ label: String,
        defaultValue : T? = nil,
        help : String? = nil
        ) {
        do {
            try self.init(label: label, defaultValue: defaultValue, help: help)
        } catch let error as Any {
            ErrorReporting.die(error)
        }
    }
}

// MARK: - Help argument

/**
Help argument. 

This is a special case of a flag argument, but is has a special meaning for the parser.

e.g. 
    
    do.swift --help

*/
public class HelpArgument : CommandLineArgument {
    
    /**

    Returns a help argument

    - parameter label: the label
    - parameter shortLabel: the short version of the label. If not specified, will default to "-h"
    - help: the help text used to describe the parameter. If not specified, will use a standard text for the help

     - throws: One of `ArgumentInitError` in case there is an error in the labels that are used

    */
    public init(
        label: String,
        shortLabel : String = "-h",
        help : String = "show this help message and exit"
        ) throws {
            try! super.init(
                label: label.addLongFlagPrefix(),
                style: ArgumentStyle.Help,
                shortLabel: shortLabel.addShortFlagPrefix(),
                help : help,
                defaultValue: false
            )
    }
    
    /**
     
     Returns a help argument with the default labels "--help" and "-h"

     */
    public convenience init() {
        do {
            try self.init(label: "--help")
        } catch let error as Any {
            ErrorReporting.die(error)
        }
    }
}
