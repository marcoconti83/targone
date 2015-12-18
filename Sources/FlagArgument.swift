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
 A flag-like command line argument
 
 A flag argument:
 - does not require any additional value
 - has a labe that starts with "--" or "-"
 - is optional
 - parses to a `Bool` value
 
 e.g. the `quiet` argument in
 
 do.swift --quiet`
 
 */

public class FlagArgument : TypedCommandLineArgument<Bool> {
    
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
                try self.init(
                    label: label,
                    shortLabel: shortLabel,
                    help: help)
            } catch let error as Any {
                ErrorReporting.die(error)
            }
    }
}
