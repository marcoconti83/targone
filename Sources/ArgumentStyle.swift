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

/// Style of command line argument
public enum ArgumentStyle {
    
    /// A flag-like argument with associated value, e.g. `--number NUMBER`
    case optional
    /// A positional argument, e.g. `file`
    case positional
    /// A flag-like argument with no associated value, e.g. `--quiet`
    case flag
    /// Help argument used to ask for help on the c
    case help
}

extension ArgumentStyle {
    
    /// Returns whether the style requires a flag-like label
    func hasFlagLikeName() -> Bool {
        switch(self) {
        case .optional:
            return true
        case .flag:
            return true
        case .help:
            return true
        case .positional:
            return false
        }
    }
    
    /// Returns whether the style requires an additional value
    func requiresAdditionalValue() -> Bool {
        switch(self) {
        case .optional:
            return true
        case .flag:
            return false
        case .positional:
            return false
        case .help:
            return false
        }
    }
    
    /// Returns whether the style requires to specify a value 
    func requiresValue() -> Bool {
        switch(self) {
        case .optional:
            return true
        case .flag:
            return false
        case .positional:
            return true
        case .help:
            return false
        }
    }
}
