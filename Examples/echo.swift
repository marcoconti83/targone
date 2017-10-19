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


// INSTRUCTIONS: 
// before running this script, make sure to run
//      carthage build --no-skip-current
// from the project folder. Then you can invoke it **from the project folder** using
//  ./Examples/echo.swift
//

import Targone

let transformMapping = [
	"upper" : { (s: String) -> String in s.uppercased() },
	"lower" : { (s: String) -> String in s.lowercased() }
]

// Define parser
var parser = ArgumentParser(summary: "Echoes some text on stdin")

// Add arguments
parser.addArgument(PositionalArgument<String>("text", help: "the text to print"))
parser.addArgument(FlagArgument("quotes", help: "enclose the text within quotes"))
parser.addArgument(OptionalArgument<String>(
	"transform", 
	shortLabel: "t", 
	help: "Transformation to apply to the text",
	choices: Array(transformMapping.keys)
	)
)

let repetitionsArg = OptionalArgument<Int>("num", shortLabel: "n", defaultValue: 1, help: "how many times to print the text")
parser.addArgument(repetitionsArg)

// Parse
let args = parser.parse()

// Extracting values, method 1: extract by argument
let repetitions = args.value(repetitionsArg)!

// Extracting values, method 2: extract by label
let text = args.stringValue("text")!
let quotes = args.boolValue("quotes")!

// Main script logic
let transformedText = { () -> String in
	if let parsed = args.stringValue("transform"), let transform = transformMapping[parsed]  {
		return transform(text)
	} else {
		return text
	}
}()

let quotedText = quotes ? "\"\(transformedText)\"" : transformedText

(0..<repetitions).forEach { _ in
	print(quotedText)
}
