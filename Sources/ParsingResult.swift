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


// MARK: - Parsing

public struct ParsingResult {
    
    /// Map from labels to values
    private let labelsToValues: [String : Any]
    
    /// Creates a parsing result from a mapping of argument labels to values.
    /// Argument labels will be stripped of the flag prefix ("--" or "-")
    init(labelsToValues: [String : Any]) {
        var noflagLabelsToValues = [String:Any]()
        labelsToValues.forEach{ (key, value) in
            noflagLabelsToValues[key.removeFlagPrefix()] = value
        }
        self.labelsToValues = noflagLabelsToValues
    }
    
    /// - returns: the value matching the argument label, only if the value
    /// is of the type expected from the argument
    /// - warning: it will abort execution and print an error if value is not of the required type
    private func value(for argument: CommandLineArgument) -> Any? {
        guard let value = labelsToValues[argument.label.removeFlagPrefix()] else { return nil }
        return (type(of: value) == argument.expectedType) ? value : nil
    }
    
    /// - returns: the value parsed for the given flag
    /// - warning: it will abort execution and print an error if value is not of the required type
    public func value(_ argument: FlagArgument) -> Bool? {
        return self.value(for: argument) as? Bool
    }
    
    /// - returns: the value parsed for the given optional argument
    /// - warning: it will abort execution and print an error if value is not of the required type
    public func value<Type>(_ argument: OptionalArgument<Type>) -> Type? {
        return self.value(for: argument) as? Type
    }
    
    /// - returns: the value parsed for the given positional argument
    /// - warning: it will abort execution and print an error if value is not of the required type
    public func value<Type>(_ argument: PositionalArgument<Type>) -> Type? {
        return self.value(for: argument) as? Type
    }
    
    /// - returns: the Bool value for the given label.
    /// - warning: it will abort execution and print an error if the value is not a Bool
    public func boolValue(_ label: String) -> Bool? {
        return (value(label, type: Bool.self) as! Bool?)
    }
    
    /// - returns: the String value for the given label.
    /// - warning: it will abort execution and print an error if the value is not a String
    public func stringValue(_ label: String) -> String? {
        return (value(label, type: String.self) as! String?)
    }

    /// - returns: the Int value for the given label.
    /// - warning: it will abort execution and print an error if the value is not an Int
    public func intValue(_ label: String) -> Int? {
        return (value(label, type: Int.self) as! Int?)
    }
    
    /// - returns: a value that is guaranteed to be of the required type if present.
    /// - warning: it will abort execution and print an error if value is not of the required type
    public func value(_ label: String, type: Any.Type) -> Any? {
        if let value = self.value(label) {
            if Swift.type(of: value) != type {
                ErrorReporting.die("value for label '\(label)' has actual type '\(Swift.type(of: label))' and not requested type '\(type.self)'")
            }
            return value
        }
        return nil
    }
    
    /// - returns: the value for the given label if present, or nil
    public func value(_ label: String) -> Any? {
        return self.labelsToValues[label]
    }
}
