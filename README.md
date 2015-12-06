![Pisa gioco del ponte](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Pisa_GiocoPonte_29061935.jpg/800px-Pisa_GiocoPonte_29061935.jpg)
# Targone

Targone is a command line argument parser for Swift scripts, inspired by [Python argparse](https://docs.python.org/2/library/argparse.html). It allows script authors to easily define what kind of arguments are expected, whether they are optional, positional or flags, and automatically generate usage description.

Its public API is designed with ease of use within a script. To achieve this, most classes have two ways of being initialized, one with explicit argument names and error reporting (throws), and a simplified version that doesn't require the fist label and that does not throw but asserts instead.

The code and the tests are documented.

A simple example Swift script usage can be found in the [Example](https://github.com/marcoconti83/targone/tree/master/Examples) folder.

## How to use Targone in your script

```import Targone```

In order to be able to import it, you need to have the `Targone.framework` in the Swift search path. You can achieve this by compiling it yourself or downloading a binary version from a release, and then invoking Swift with the `-F` argument, pointing to the folder where Targone is stored.

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
