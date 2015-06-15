# QRCoder

[![CI Status](http://img.shields.io/travis/sbhklr/QRCoder.svg?style=flat)](https://travis-ci.org/sbhklr/QRCoder)
[![Version](https://img.shields.io/cocoapods/v/QRCoder.svg?style=flat)](http://cocoapods.org/pods/QRCoder)
[![License](https://img.shields.io/cocoapods/l/QRCoder.svg?style=flat)](http://cocoapods.org/pods/QRCoder)
[![Platform](https://img.shields.io/cocoapods/p/QRCoder.svg?style=flat)](http://cocoapods.org/pods/QRCoder)

Since OSX 10.9 / iOS 7 apple offers a CI filter to generate QR codes.
However, scaling the QR code to the desired size without blurring the image doesn't work out of the box. The QRCoder library can help you with that. It also contains a handy view controller to scan QR codes.

## Usage

Simply QRCodeGenerator to create an image of type QRImage. This is a type alias for UIImage under iOS and NSImage under OS X.

<img src="https://raw.githubusercontent.com/sbhklr/QRCoder/master/screenshots/ios_code.png" width="250" />
```swift
let generator = QRCodeGenerator()
//You can set the correction level to one of [L,M,Q,H]
//Default correction level is M
generator.correctionLevel = .H
let image:QRImage = generator.createImage("Hello world!",size: CGSizeMake(200,200))
```
<img src="https://raw.githubusercontent.com/sbhklr/QRCoder/master/screenshots/osx_code.png" width="300" />
```swift
let generator = QRCodeGenerator()
let image:QRImage = generator.createImage("Hello world!",size: CGSizeMake(200,200))
```
<img src="https://raw.githubusercontent.com/sbhklr/QRCoder/master/screenshots/ios_scanner.png" width="250" />
```swift
class ScannerViewController : QRCodeScannerViewController {

    override func processQRCodeContent(qrCodeContent: String) -> Bool {
        println(qrCodeContent)
        dismissViewControllerAnimated(true, completion: nil)
        return true
    }

}
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Requires OS X 10.9 / iOS 8.

## Installation

QRCoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QRCoder"
```

## Author

Sebastian Hunkeler, @sbhklr

## License

QRCoder is available under the MIT license. See the LICENSE file for more info.
