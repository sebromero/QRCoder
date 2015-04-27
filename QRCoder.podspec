Pod::Spec.new do |s|
s.name             = "QRCoder"
s.version          = "0.1.0"
s.summary          = "A QR code generator and reader for OSX and iOS written in Swift."
s.description      = <<-DESC
Since OSX 10.9 apple offers a CI filter to generate QR codes.
However, scaling the QR code to the desired size without blurring
the image doesn't work out of the box. That's why I created this library.
DESC
s.homepage         = "https://github.com/sbhklr/QRCodeGenerator"
# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
s.license          = 'MIT'
s.author           = { "Sebastian Hunkeler" => "sebastian.hunkeler@iml.unibe.ch" }
s.source           = { :git => "https://github.com/sbhklr/QRCodeGenerator.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/sbhklr'

s.platform     = :osx, '10.9'
s.requires_arc = true

s.source_files = 'Pod/Classes/QRCoder.swift'

#s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'Foundation', 'AppKit', 'QuartzCore'
# s.dependency 'AFNetworking', '~> 2.3'
end
