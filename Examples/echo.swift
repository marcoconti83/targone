#!/usr/bin/swift -F Carthage/Build/Mac
// Copyright (c) 2015  Marco Conti
//
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
//
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Targone

// Define parser
var parser = ArgumentParser(summary: "Echoes some text on stdin")

// Method 1: add and retrieve final value by argument
let repetitionsArg = OptionalArgument<Int>("num", shortLabel: "n", defaultValue: 1, help: "how many times to print the text")
parser.addArgument(repetitionsArg) 
let textArg = PositionalArgument<String>("text")
parser.addArgument(textArg)

// Method 2: add and retrieve final value by label
parser.addArgument(FlagArgument("quotes", help: "enclode text within quotes"))

// Parse
let args = parser.parse()


// Method 1:
let repetitions = args.value(repetitionsArg)!
let text = args.value(textArg)!

// Method 2: (requires explicit casting)
let quotes = args.labelsToValues["--quotes"] as! Bool

for i in 0..<repetitions {
	print(quotes ? "\"\(text)\"" : text)
}
