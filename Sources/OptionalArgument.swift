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
 An optional command line argument
 
 An optional argument:
 - requires a following additional value
 - has a label that starts with "--" or "-"
 - is optional
 
 e.g. the `speed` argument in
 
 do.swift --speed 10
 
 */
public class OptionalArgument<T> : TypedCommandLineArgument<T> where T: InitializableFromString {
    
    /**
     Returns an optional argument.
     
     - parameter label: the label. If the flag prefix ("--") is missing, will automatically add it
     - parameter shortLabel: the short version of the label (e.g. "-f"). If the short flag prefix is missing, will automatically add it
     - parameter help: the help text used to describe the parameter
     - parameter defaultValue: if the argument is not present on the command line, it will be set to the given default value. If no default value is given,
     it will be set to `nil`
     - parameter choices: a list of possible values for the argument. Passing an argument that is not in this list (if the list is specified)
     will result in a parsing error
     - throws: One of `ArgumentInitError` in case there is an error in the labels that are used
     */
    public init(
        label: String,
        shortLabel : String? = nil,
        defaultValue : T? = nil,
        help : String? = nil,
        choices: [T]? = nil
        ) throws
    {
        try super.init(
            label: label.addLongFlagPrefix(),
            style: ArgumentStyle.Optional,
            shortLabel: shortLabel?.addShortFlagPrefix(),
            defaultValue : defaultValue,
            help : help,
            choices: choices
        )
    }
    
    /**
     Returns an optional argument. This is the error-free version of the other `init`. It will assert in case of error.
     
     - parameter label: the label. If the flag prefix ("--") is missing, will automatically add it
     - parameter shortLabel: the short version of the label (e.g. "-f"). If the short flag prefix is missing, will automatically add it
     - parameter help: the help text used to describe the parameter
     - parameter defaultValue: if the argument is not present on the command line, it will be set to the given default value. If no default value is given,
     it will be set to `nil`
     - parameter choices: a list of possible values for the argument. Passing an argument that is not in this list (if the list is specified)
     will result in a parsing error
     */
    public convenience init(
        _ label: String,
        shortLabel : String? = nil,
        defaultValue : T? = nil,
        help : String? = nil,
        choices: [T]? = nil
        ) {
            do {
                try self.init(
                    label: label,
                    shortLabel: shortLabel,
                    defaultValue: defaultValue,
                    help: help,
                    choices: choices)
            } catch let error as Any {
                ErrorReporting.die(error)
            }
    }
}
