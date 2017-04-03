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
public enum ArgumentInitError : Error {

    /// Can not specify a flag-like label when the argument is not optional
    case labelCanNotBeFlagIfArgumentIsPositional
    /// Short label (`-n`) can't be a long flag (`--number`)
    case shortLabelCanNotBeLongFlag
    /// Invalid label
    case invalidLabel
    
}

/**
 
 An argument expected on the command line.
 
 */
open class CommandLineArgument {
    
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
    
    /// List of accepted values, if any
    fileprivate let choices : [Any]?
    
    /// The expected type of this parameter
    let expectedType : Any.Type
    
    /**
     Creates a command line argument
     - parameter label: the label. For non positional arguments, it will be used to generate the description and to identify
     the argument. For flag-like arguments, in addition, it will also be the label (prefixed with --) used to specify the
     argument (e.g. `--label 2`).
     - parameter style: the style of the argument
     - parameter shortLabel: a short version of the label, for flag-like arguments (e.g. `--label` can be shortened to `-l`)
     - parameter defaultValue: the default value to return when parsing, if no value is actually provided. If no value is specified,
     the parsing will fail if the value is not specified
     - parameter help: a help string used to describe how the argument should be used
     - parameter choices: a list of possible values for the argument. Passing an argument that is not in this list (if the list is specified)
    will result in a parsing error.
     */
    init<Type>(
        label: String,
        style: ArgumentStyle,
        shortLabel: String? = nil,
        defaultValue : Type?? = nil,
        help : String? = nil,
        choices : [Type]? = nil
        ) throws where Type : InitializableFromString
    {
        self.label = label
        self.shortLabel = shortLabel
        self.defaultValue = defaultValue
        self.help = help
        self.style = style
        self.expectedType = Type.self
        self.choices = choices?.map { $0 as Any } // didn't find another way of making the compiler happy about the conversion :(
        
        if self.allLabels.filter({ !$0.isValidArgumentName() }).count > 0 {
            throw ArgumentInitError.invalidLabel
        }
    
        if let shortLabel = shortLabel , shortLabel.isLongFlagStyle() {
            throw ArgumentInitError.shortLabelCanNotBeLongFlag
        }
    }
    
    /// Attempts to parse a token matching the argument.
    /// returns `nil` if it was not possible to parse a valid value
    func parseValue(_ token: String) throws -> Any? {
        return nil
    }
}

// MARK: - Hashable

extension CommandLineArgument : Hashable {
    
    public var hashValue : Int {
        return self.label.hashValue ^ (self.shortLabel?.hashValue ?? 0)
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
    
    /// Whether this argument is optional
    var isOptional : Bool {
        switch(self.style) {
        case .positional:
            return false
        default:
            return true
        }
    }
}

// MARK: - String representation

extension CommandLineArgument : CustomStringConvertible {

    /// Returns the type specification needed for the given type
    fileprivate func placeholderArgumentDescription() -> String {
        if self.style.requiresAdditionalValue() {
            return " "+self.label.placeholderArgumentString()
        }
        return ""
    }
    
    /// Returns the type specifications according to the expected type (none for String, <Type> for any other)
    fileprivate func typeSpecificationDescription() -> String {
        if self.expectedType == String.self || !self.style.requiresValue() {
            return ""
        }
        return "<\(self.expectedType)>"
    }

    /// Returns the argument and the expected value placeholder, if any
    var compactLabelWithExpectedValue : String {
        return self.compactLabel + self.placeholderArgumentDescription() + self.typeSpecificationDescription()
    }

    /// First line of the description: parameters and help
    fileprivate var firstLineOfDescription : String {
        
        let placeholderArgument = self.placeholderArgumentDescription() + self.typeSpecificationDescription()
        let firstColumn = "\(label)" +
            (self.shortLabel != nil ? ", "+shortLabel! : "" ) +
        placeholderArgument
        let secondColumn = self.help
        
        let needsPadding = firstColumn.characters.count < OutputFirstColumnPadding
        let paddedFirstColumn = needsPadding ?
            firstColumn.padding(toLength: OutputFirstColumnPadding, withPad: " ", startingAt: 0) :
            firstColumn + " "
        
        if let secondColumn = secondColumn {
            return paddedFirstColumn + secondColumn
        }
        else {
            return firstColumn
        }
    }
    
    
    public var description : String {
        
        if let choices = self.choices {
            let choicesDescription = choices.map { "'\($0)'"}.joined(separator: " | ")
            return self.firstLineOfDescription + "\n\t\t" + "Possible values: " + choicesDescription
        } else {
            return self.firstLineOfDescription
        }
    }
}


// MARK: - Typed command line argument

/**
This intermediate class is needed because CommandLineArgument has to have no generic type
to be able to be stored in collections, but the class needs to have a generic parameter
to be able to initalize and compare
*/
public class TypedCommandLineArgument<T> : CommandLineArgument where T : InitializableFromString {
    
    override func parseValue(_ token: String) throws -> Any? {
        if let parsedValue = T(initializationString: token) {
            if let choices = self.choices {
                let unwrappedChoices = choices.map { $0 as! T}
                // don't want to use set as it will impose a Hashable restricition. Linear search.
                let choicesContainToken = unwrappedChoices.filter({ $0 == parsedValue }).count > 0
                if choicesContainToken {
                    return parsedValue
                }
                else {
                    throw CommandLineArgumentParsingError.notInChoices(argument: self, validChoices: unwrappedChoices.map { $0 as Any}, token: token)
                }
            }
            return parsedValue
        }
        return CommandLineArgumentParsingError.invalidType(argument: self, token: token)
    }
    
    override init<Type>(
        label: String,
        style: ArgumentStyle,
        shortLabel: String? = nil,
        defaultValue : Type?? = nil,
        help : String? = nil,
        choices : [Type]? = nil
        ) throws where Type : InitializableFromString
    {
        try super.init(
            label: label,
            style: style,
            shortLabel: shortLabel,
            defaultValue: defaultValue,
            help: help,
            choices: choices)
    }
}
