Pod::Spec.new do |s|
s.name             = "QRCoder"
s.version          = "1.1.0"
s.summary          = "A QR code generator and scanner for OSX and iOS written in Swift."
s.description      = <<-DESC
Since OSX 10.9 / iOS 7 apple offers a CI filter to generate QR codes.
However, scaling the QR code to the desired size without blurring
the image doesn't work out of the box. The QRCoder library can help you with that.
It also contains a handy view controller to scan QR codes.
DESC

s.homepage         = "https://github.com/sbhklr/QRCoder"
s.screenshots     = "https://raw.githubusercontent.com/sbhklr/QRCoder/master/screenshots/ios_code.png", "https://raw.githubusercontent.com/sbhklr/QRCoder/master/screenshots/osx_code.png", "https://raw.githubusercontent.com/sbhklr/QRCoder/master/screenshots/ios_scanner.png"
s.license          = 'MIT'
s.author           = { "Sebastian Hunkeler" => "hunkeler.sebastian@gmail.com" }
s.source           = { :git => "https://github.com/sbhklr/QRCoder.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/sbhklr'

s.requires_arc = true
s.ios.source_files = 'Pod/Classes/*.swift'
s.osx.source_files = 'Pod/Classes/QRCodeGenerator.swift'

s.ios.deployment_target = "8.0"
s.osx.deployment_target = "10.9"

s.swift_version= '4.1'

s.ios.frameworks = 'Foundation', 'UIKit', 'QuartzCore'
s.osx.frameworks = 'Foundation', 'AppKit', 'QuartzCore'

end
