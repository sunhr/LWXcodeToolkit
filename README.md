# LWXcodeToolkit

[![Build Status](https://travis-ci.org/sunhr/LWXcodeToolkit.svg?branch=master)](https://travis-ci.org/sunhr/LWXcodeToolkit)


Extensions for Xcode 8+

## Features

### Importer

![image](https://raw.githubusercontent.com/sunhr/LWXcodeToolkit/master/doc/Importer/function.gif)

### Assume Nonnull

* Add `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END` macros in your `.h` files

![image](https://raw.githubusercontent.com/sunhr/LWXcodeToolkit/master/doc/AssumeNonnull/feature1.gif)


* Add default categories in your `.m` and `.mm` files

![image](https://raw.githubusercontent.com/sunhr/LWXcodeToolkit/master/doc/AssumeNonnull/feature2.gif)

## How to Use

1. Setup Code Signing for Target `LWXcodeToolkitContainer` and `LWXcodeToolkit` by applying your own Team
2. Build Target `LWXcodeToolkitContainer`
3. Copy `LWXcodeToolkitContainer.app` from `Products` to your `Applications` folder
4. Open `LWXcodeToolkitContainer.app` then close it
5. Open `Preference - Extension` of macOS, make sure `LWXcodeToolkit` is selected as Xcode Source Editor
6. Restart Xcode and enjoy it, add shortcuts if you like