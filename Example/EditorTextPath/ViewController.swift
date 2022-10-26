//
//  ViewController.swift
//  EditorTextPath
//
//  Created by Mehdi Sohrabi on 10/09/2022.

import TextPath
import UIKit
import WebKit

class ViewController: UIViewController {
    lazy var textView: UITextView = {
        let view = UITextView()
        view.attributedText = sampleText
        view.isScrollEnabled = false
        view.delegate = self
        view.sizeToFit()

        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.blue.cgColor

        return view
    }()

    lazy var pathView: CGPathView = .init(frame: .zero)

    lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero)

        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.green.cgColor

        return view
    }()

    lazy var sampleText: NSAttributedString = {
        let text = NSMutableAttributedString(string: "Example\ntext")

        var style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        style.alignment = .right

        text.addAttributes([.font: UIFont.systemFont(ofSize: 38, weight: .bold),
                            .foregroundColor: UIColor.black,
                            .strikethroughStyle: 1,
                            .underlineStyle: 1,
                            .paragraphStyle: style],
                           range: NSRange(location: 0, length: text.length))
        return text
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    private func setupUI() {
        view.addSubview(textView)
        view.addSubview(pathView)
        view.addSubview(webView)
    }

    private func fillWebView(_ svgPath: String) {
        let svg = """
            <svg width="100%" height="auto" viewBox="0 0 \(webView.frame.width) \(webView.frame.height)" xmlns="http://www.w3.org/2000/svg">
              <path id="textPath" d="\(svgPath)" stroke-width="none" fill="#000"></path>
            </svg>
        """

        let html = """
            <html lang="en">
                <body>
                    <div>\(svg)</div>
                </body>
            </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }
}

private extension ViewController {
    func updateUI() {
        Task {
            textView.frame.size.width = view.frame.width
            textView.sizeToFit()
            textView.center = view.center

            pathView.frame = textView.frame
            pathView.frame.origin.y += pathView.frame.height + 8.0

            webView.frame = pathView.frame
            webView.frame.origin.y += webView.frame.height + 8.0

            let path = await textView.attributedText.getTextPath(InBounds: textView.bounds.size)?.composedPath
            pathView.path = path

            let svg = await path?.svg() ?? ""
            fillWebView(svg)

            print(svg)
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        updateUI()
    }
}
