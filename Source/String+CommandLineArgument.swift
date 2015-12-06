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


extension String {
    
    private static let LongFlagPrefix = "--"
    private static let ShortFlagPrefix = "-"
    
    /// Returns whether self has the prefix that identifies the
    /// argument as a long flag
    func isLongFlagStyle() -> Bool {
        return self.hasPrefix(String.LongFlagPrefix)
    }
    
    /// Returns whether self has the prefix that identifies the
    /// argument as a short flag
    func isShortFlagStyle() -> Bool {
        return self.hasPrefix(String.ShortFlagPrefix) && !self.isLongFlagStyle()
    }
    
    /// Returns whether self is a long flag or short flag style
    func isFlagStyle() -> Bool {
        return self.isLongFlagStyle() || self.isShortFlagStyle()
    }
    
    /// Prepends "--" to self, if it's not already present or `self` starts with "-"
    func addLongFlagPrefix() -> String {
        if self.isFlagStyle() {
            return self
        }
        return String.LongFlagPrefix + self
    }
    
    /// Prepends "-" to `self`, if it's not already present
    func addShortFlagPrefix() -> String {
        if self.isFlagStyle() {
            return self
        }
        return String.ShortFlagPrefix + self
    }
    
    /// Returns `self` without the flag prefix ("--" or "-")
    func removeFlagPrefix() -> String {
        if(self.isLongFlagStyle()) {
            return self.substringFromIndex(self.startIndex.advancedBy(2))
        }
        if(self.isShortFlagStyle()) {
            return self.substringFromIndex(self.startIndex.advancedBy(1))
        }
        return self
    }
    
    /**
     
    Returns `self` transformed to the format of a placeholder argument
     e.g. from 
     
         --output-file
     
     to 
     
         OUTPUT_FILE

    */
    func placeholderArgumentString() -> String {
        var output = self.removeFlagPrefix()
        output = String(output.characters.map { $0 == "-" ? "_" : $0 })
        return output.uppercaseString
    }
    
    /**
        Returns whether the string is a valid argument name according to
        the following rules
     
        - can have a "-" or "--" prefix
        - after the prefix (if any) or at the first character (if it has no prefix),
            there should be a lowercase or uppercase letter or "_"
        - there can be no spaces and no puctuation symbol other than "_" or "-"
    */
    func isValidArgumentName() -> Bool {
        let withoutPrefix = self.removeFlagPrefix()
        
        if withoutPrefix.characters.count == 0 {
            return false
        }
        
        // does it have spaces?
        if let _ = withoutPrefix.rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            return false
        }
        
        // does it start with letter?
        let firstLetterCharacterSet = NSMutableCharacterSet.letterCharacterSet()
        firstLetterCharacterSet.addCharactersInString("_")
        if !firstLetterCharacterSet.characterIsMember(withoutPrefix.utf16.first!) {
            return false
        }
        
        // does it contains only alphanumeric and _ and -?
        let validCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        validCharacterSet.addCharactersInString("-_")
        if let _ = withoutPrefix.rangeOfCharacterFromSet(validCharacterSet.invertedSet) {
            return false
        }
        
        return true
    }
}
