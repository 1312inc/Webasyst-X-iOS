//
//  BlogEntryViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/26/21.
//
import UIKit
import WebKit

class BlogEntryViewController: UIViewController, WKUIDelegate {
    
    var viewModel: BlogEntryViewModelProtocol!
    private var webViewHeight: CGFloat = 0
    
    //Interface element variables
    lazy var textView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setupLayout()
        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundColor")
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.barTintColor = UIColor.systemGray6
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    private func setupData() {
        self.textView.scrollView.bounces = false
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></HEAD><BODY style=\"background-color: \(UIColor.systemBackground.htmlRGB)\">"
        let htmlEnd = "</BODY></HTML>"
        let text = self.viewModel.blogEntry.text.replacingOccurrences(of: " style=\"width: 970px;\"", with: "")
        let replacedText = text.replacingOccurrences(of: "<p>", with: "<p style=\"color: \(UIColor.label.htmlRGB)\">")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: self.viewModel.blogEntry.datetime)!
        dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
        let somedateString = dateFormatter.string(from: myDate)
        let fullHTML = "<style type=\"text/css\">" +
            "img {" +
                "max-width: 100%;" +
                "max-height: 100%;" +
            "};" +
            "</style>" +
            "<body id=\"page\">" +
                "<h1 style=\"color: \(UIColor.label.htmlRGB)\">" + self.viewModel.blogEntry.title + "</h1>" +
            "<span style=\"color: \(UIColor.label.htmlRGB)\">" + somedateString + "</span>" +
            "\(replacedText)</body></html>"
        self.textView.loadHTMLString("\(htmlStart)\(fullHTML)\(htmlEnd)", baseURL:  nil)
    }
    
    private func setupLoadingView() {
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            self.loadingView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.loadingView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
    
    private func setupLayout() {
        loadingView.removeFromSuperview()
        textView.backgroundColor = UIColor(named: "backgroundColor")
        self.view.addSubview(textView)
        NSLayoutConstraint.activate([
            self.textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.textView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            self.textView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor),
            self.textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0, 0, 0, 0)
    }

    // hue, saturation, brightness and alpha components from UIColor**
    var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return (hue, saturation, brightness, alpha)
        }
        return (0,0,0,0)
    }

    var htmlRGB: String {
        return String(format: "#%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
    }

    var htmlRGBA: String {
        return String(format: "#%02x%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255), Int(rgba.alpha * 255) )
    }
}
