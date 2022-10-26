# TextPath

![Platform](https://img.shields.io/badge/platform-iOS-green) [![build](https://github.com/mehdok/TextPath/actions/workflows/build.yml/badge.svg)](https://github.com/mehdok/TextPath/actions/workflows/build.yml)

Convert `NSAttributedText` to `CGPath` and `SVG` text path;

Supported attributes are:
- [x] NSAttributedString.Key.strikethroughStyle
- [x] NSAttributedString.Key.underlineStyle
- [x] NSAttributedString.Key.kern
- [x] NSAttributedString.Key.font
- [x] NSAttributedString.Key.paragraphStyle
- [ ] Support RTL language
- [x] Support right alignment texts

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Installation

To install it, simply add the following line to your Podfile:

```ruby
pod 'TextPath'
```

You can also use SPM;

## Author

Mehdi Sohrabi, mehdok@gmail.com
Heavily based on https://github.com/malczak/TextPaths

## License

TextPath is available under the MIT license. See the LICENSE file for more info.

## Further Reading
- https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html
- https://www.appcoda.com/intro-text-kit-ios-programming-guide/
- https://developer.apple.com/documentation/appkit/textkit/using_textkit_2_to_interact_with_text
- https://metalbyexample.com/text-3d/
- https://github.com/eugenebokhan/metal-3d-text
- https://github.com/RazrFalcon/resvg
- http://pawlan.com/monica/articles/texttutorial/other.html
- https://www.raywenderlich.com/5960-text-kit-tutorial-getting-started
