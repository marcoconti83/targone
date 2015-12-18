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
    public let labelsToValues: [String : Any]
    
    init(labelsToValues: [String : Any]) {
        self.labelsToValues = labelsToValues
    }
    
    /// Returns the value matching the argument label, only if the value
    /// is of the type expected from the argument
    private func valueForArgument(argument: CommandLineArgument) -> Any? {
        guard let value = labelsToValues[argument.label] else { return nil }
        let mirror = Mirror(reflecting: value)
        return (mirror.subjectType == argument.expectedType) ? value : nil
    }
    
    /// Returns the value parsed for the given flag
    public func value(argument: FlagArgument) -> Bool? {
        return self.valueForArgument(argument) as? Bool
    }
    
    /// Returns the value parsed for the given optional argument
    public func value<Type>(argument: OptionalArgument<Type>) -> Type? {
        return self.valueForArgument(argument) as? Type
    }
    
    /// Returns the value parsed for the given positional argument
    public func value<Type>(argument: PositionalArgument<Type>) -> Type? {
        return self.valueForArgument(argument) as? Type
    }
    
    /// Returns the Bool value for the given label.
    /// It will assert if the value is not a boolean or not present
    public func boolValue(label: String) -> Bool {
        return self.labelsToValues[label] as! Bool
    }
    
    /// Returns the String value for the given label.
    /// It will assert if the value is not a boolean or not present
    public func value(label: String) -> String {
        return self.labelsToValues[label] as! String
    }

    /// Returns the Int value for the given label.
    /// It will assert if the value is not a boolean or not present
    public func intValue(label: String) -> Int {
        return self.labelsToValues[label] as! Int
    }
}
