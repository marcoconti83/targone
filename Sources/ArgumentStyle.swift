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
    case Optional
    /// A positional argument, e.g. `file`
    case Positional
    /// A flag-like argument with no associated value, e.g. `--quiet`
    case Flag
    /// Help argument used to ask for help on the c
    case Help
}

extension ArgumentStyle {
    
    /// Returns whether the style requires a flag-like label
    func hasFlagLikeName() -> Bool {
        switch(self) {
        case Optional:
            return true
        case Flag:
            return true
        case Help:
            return true
        case .Positional:
            return false
        }
    }
    
    /// Returns whether the style requires an additional value
    func requiresAdditionalValue() -> Bool {
        switch(self) {
        case Optional:
            return true
        case Flag:
            return false
        case .Positional:
            return false
        case .Help:
            return false
        }
    }
    
    /// Returns whether the style requires to specify a value 
    func requiresValue() -> Bool {
        switch(self) {
        case Optional:
            return true
        case Flag:
            return false
        case .Positional:
            return true
        case .Help:
            return false
        }
    }
}