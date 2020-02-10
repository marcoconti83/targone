![Pisa gioco del ponte](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Pisa_GiocoPonte_29061935.jpg/800px-Pisa_GiocoPonte_29061935.jpg)
# Targone [![Build Status](https://travis-ci.org/marcoconti83/targone.svg?branch=master)](https://travis-ci.org/marcoconti83/targone)

Targone is a command line argument parser for Swift scripts, inspired by [Python argparse](https://docs.python.org/2/library/argparse.html). It allows script authors to easily define what kind of arguments are expected, whether they are optional, positional or flags, and automatically generate usage description.

See also [Morione](https://github.com/marcoconti83/morione), A Swift subprocess execution library intended to be used in Swift scripts, inspired by Python `subprocess`.

## API design

Targone public API is designed keeping in mind ease of use within a script. 

To achieve this, most classes have two ways of being initialized, one with explicit argument names and error reporting (Swift `throw`), and one simplified version that doesn't require the first label and that does not throw. The second version will instead print an error and aborts execution, following a common pattern in scripts where not all edge cases need to be handled explicitly and abrupt abortion is a valid strategy. See [`OptionalArgument`](https://github.com/marcoconti83/targone/blob/28cf21701b7c92cc744e0e1fd885bfcefa6d9b32/Sources/CommandLineArgument.swift) for an example.

To extract a parsed value (see [`ParsingResult`](https://github.com/marcoconti83/targone/blob/48c4179fc6c9b7ab6510a98971f890b83903219c/Sources/ParsingResult.swift)), one could use a function that return `nil` if the expected type does not match, or a function that prints an error and aborts execution if the type doesn't match.

Aborting execution does not sound very Swift-like; on the other hand, throwing a Swift-error would make even the most simple script full of `try!` and in case of error, print some completely cryptic stack trace that has nothing to do with the error itself. As the goal of Targone is ease of use in a script, we decided not to use `throw`. We are aware that this makes it impossible to test some cases in unit tests.

The API is documented in the code and tests.

A simple example Swift script usage can be found in the [Example](https://github.com/marcoconti83/targone/tree/master/Examples) folder.

## Examples

Prints an error when command line arguments are missing or not matching type
```
$> Examples/echo.swift
usage: echo.swift [-h] [-n NUM<Int>] [--quotes] text
echo.swift: error: too few arguments
```

Automatically generates and prints help
```
$> Examples/echo.swift --help
sage: echo.swift [-h] [--quotes] [-n NUM<Int>] text

Echoes some text on stdin

positional arguments:
text                          the text to print

optional arguments:
--help, -h                    show this help message and exit
--num, -n NUM<Int>            how many times to print the text
--quotes                      enclose the text within quotes
```

## How to use Targone in your script

Just add ```import Targone``` to your script

In order to be able to import it, you need to have the `Targone.framework` in the Swift search path. You can achieve this by compiling it yourself or downloading a binary version from a release. You need to invoke Swift with the `-F` argument, pointing to the folder where Targone is stored.

### Carthage integration
Targone can be downloaded locally with [Carthage](https://github.com/Carthage/Carthage). 

Just add 

```github "marcoconti83/targone"```

to your `Cartfile`. After running

```carthage update```

you would be able to run any swift file with

```swift -F Carthage/Build/Mac```

The `-F` flag can also be included in the [shebang](https://en.wikipedia.org/wiki/Shebang_%28Unix%29) line of the script, so that you can just invoke the script directly (e.g. ```$> do.swift```). This is the approach used in the [examples](https://github.com/marcoconti83/targone/tree/master/Examples) included with this project.

### Without Carthage
You can download the framework binary from the GitHub [latest release](https://github.com/marcoconti83/targone/releases/latest)
