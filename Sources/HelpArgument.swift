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
        shortLabel : String? = nil,
        help : String = "show this help message and exit"
        ) throws {
            try super.init(
                label: label.addLongFlagPrefix(),
                style: ArgumentStyle.Help,
                shortLabel: shortLabel?.addShortFlagPrefix(),
                help : help,
                defaultValue: false
            )
    }
    
    /**
     
     Returns a help argument with the default labels "--help" and "-h"
     
     */
    public convenience init() {
        do {
            try self.init(label: "--help", shortLabel: "-h")
        } catch let error as Any {
            ErrorReporting.die(error)
        }
    }
}
