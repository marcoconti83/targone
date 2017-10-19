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
 Can be initialized from a string, but the initialization can fail in case the string
 does not represent a valid instance
*/
public protocol InitializableFromString : Equatable {
    
    /// Fails initialization if the string does not represent a valid instance of the type
    init?(initializationString: String)
}

extension Int : InitializableFromString {
    
    public init?(initializationString: String) {
        self.init(initializationString)
    }
}

extension Double : InitializableFromString {
    
    public init?(initializationString: String) {
        self.init(initializationString)
    }
}

extension String : InitializableFromString {
    
    public init?(initializationString: String) {
        self.init(initializationString)
    }
}

/// Strings that are considered true when initializing a Bool
private let TrueStringValues = Set(["1","true","TRUE"])

/// Strings that are considered false when initializing a Bool
private let FalseStringValues = Set(["0","false","FALSE"])

extension Bool : InitializableFromString {
    
    /**
     Will initialize to true with the values:
        - 1
        - true
        - TRUE
     Will initialize to false with the values:
        - 0
        - false
        - FALSE
     Will fail to initialize on any other value
    */
    public init?(initializationString: String) {
        
        switch(initializationString) {
        case let t where TrueStringValues.contains(t):
            self.init(true)
        case let f where FalseStringValues.contains(f):
            self.init(false)
        default:
            return nil
        }
    }
}

