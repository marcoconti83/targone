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


import XCTest
@testable import Targone

class String_CommandLineArgumentTests: XCTestCase {

    func testThatItDetectsFlags() {
        XCTAssertTrue("-b".isFlagStyle())
        XCTAssertTrue("--boo".isFlagStyle())
        XCTAssertFalse("boo".isFlagStyle())
    }

    func testThatItDetectsShortFlag() {
        XCTAssertTrue("-b".isShortFlagStyle())
        XCTAssertFalse("--boo".isShortFlagStyle())
        XCTAssertFalse("boo".isShortFlagStyle())
    }
    
    func testThatItDetectsLongFlag() {
        XCTAssertFalse("-b".isLongFlagStyle())
        XCTAssertTrue("--boo".isLongFlagStyle())
        XCTAssertFalse("boo".isLongFlagStyle())
    }
    
    func testThatItAddsShortFlagPrefix() {
        XCTAssertEqual("boo".addShortFlagPrefix(), "-boo")
        XCTAssertEqual("-b".addShortFlagPrefix(), "-b")
        XCTAssertEqual("--boo".addShortFlagPrefix(), "--boo")
    }

    func testThatItAddsLongFlagPrefix() {
        XCTAssertEqual("boo".addLongFlagPrefix(), "--boo")
        XCTAssertEqual("-b".addLongFlagPrefix(), "-b")
        XCTAssertEqual("--boo".addLongFlagPrefix(), "--boo")
    }

    func testThatItReturnsremoveFlagPrefix() {
        XCTAssertEqual("boo".removeFlagPrefix(), "boo")
        XCTAssertEqual("-b".removeFlagPrefix(), "b")
        XCTAssertEqual("--boo".removeFlagPrefix(), "boo")
    }

    func testThatItReturnsPlaceholderArgumentString() {
        XCTAssertEqual("boo".placeholderArgumentString(), "BOO")
        XCTAssertEqual("-b".placeholderArgumentString(), "B")
        XCTAssertEqual("--boo".placeholderArgumentString(), "BOO")
        XCTAssertEqual("--boo_foo".placeholderArgumentString(), "BOO_FOO")
    }
    
    func testThatItValidatesArgumentNames() {
        // flag
        XCTAssertTrue("-f".isValidArgumentName())
        XCTAssertTrue("--foo".isValidArgumentName())
        // no flag
        XCTAssertTrue("foo".isValidArgumentName())
        // dashes
        XCTAssertTrue("--fo-o".isValidArgumentName())
        // underscore
        XCTAssertTrue("_foo".isValidArgumentName())
        XCTAssertTrue("--fo_o".isValidArgumentName())
        // uppercase
        XCTAssertTrue("FOO".isValidArgumentName())
        // numbers
        XCTAssertTrue("foo32d1".isValidArgumentName())
    }
    
    func testThatThatItDoesNotValidaArgumentNames() {
        // first character is not letter or _
        XCTAssertFalse("1erf".isValidArgumentName())
        XCTAssertFalse("---foo".isValidArgumentName())
        
        // contains spaces
        XCTAssertFalse("fo o".isValidArgumentName())
        XCTAssertFalse("fo\no".isValidArgumentName())
        XCTAssertFalse("fo\to".isValidArgumentName())
        
        // contains special chars
        let forbidden = "<>.?/!+=&🏀⛳️#^*,\\$@~:;(){}[]\"'`"
        for invalidRawChar in forbidden.characters {
            let invalidString = String(invalidRawChar)
            XCTAssertFalse("fo\(invalidString)o".isValidArgumentName())
        }
        
        // empty
        XCTAssertFalse("".isValidArgumentName())
    }

}
