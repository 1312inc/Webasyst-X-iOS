//
//  BlogEntryViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/26/21.
//

import UIKit
import WebKit

class BlogEntryViewController: UIViewController {
    
    var viewModel: BlogEntryViewModelProtocol!
    private var webViewHeight: CGFloat = 0
    
    //Interface element variables
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var textView: WKWebView = {
        let label = WKWebView()
        label.navigationDelegate = self
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setupLoadingView()
        self.setupData()
    }
    
    private func setupData() {
        self.titleLabel.text = self.viewModel.blogEntry.title
        self.textView.scrollView.bounces = false
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        let text = self.viewModel.blogEntry.text.replacingOccurrences(of: " style=\"width: 970px;\"", with: "")
        let fullHTML = "<!DOCTYPE html>" +
            "<html lang=\"ja\">" +
            "<head>" +
            "<meta charset=\"UTF-8\">" +
            "<style type=\"text/css\">" +
            "html{margin:0;padding:0;}" +
            "body {" +
            "margin: 0;" +
            "padding: 0;" +
            "color: #363636;" +
            "font-size: 90%;" +
            "line-height: 1.6;" +
            "}" +
            "img{" +
            "position: -webkit-sticky;" +
            "top: 0;" +
            "bottom: 0;" +
            "left: 0;" +
            "right: 0;" +
            "max-width: 100%;" +
            "max-height: 100%;" +
            "}" +
            "</style>" +
            "</head>" +
            "<body id=\"page\">" +
            "\(text)</body></html>"
        self.textView.loadHTMLString("\(htmlStart)\(fullHTML)\(htmlEnd)", baseURL:  nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: self.viewModel.blogEntry.datetime)!
        dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
        let somedateString = dateFormatter.string(from: myDate)
        self.dateLabel.text = somedateString
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
    
    private func setupLayout(webViewHeight: CGFloat) {
        loadingView.removeFromSuperview()
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(containerView)
        self.containerView.addSubview(titleLabel)
        self.containerView.addSubview(dateLabel)
        self.containerView.addSubview(textView)
        self.scrollView.contentSize = textView.frame.size
        NSLayoutConstraint.activate([
            self.scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            self.scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            self.containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            self.containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: -40),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10),
            self.dateLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.textView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 10),
            self.textView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.textView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.textView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            self.textView.heightAnchor.constraint(equalToConstant: webViewHeight),
            self.textView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
    }
}

extension BlogEntryViewController: UIWebViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension BlogEntryViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.textView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.textView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (result, error) in
                    if let height = result as? CGFloat {
                        let heigthWebView = self.textView.frame.size.height + height
                        self.setupLayout(webViewHeight: heigthWebView)
                    }
                })
            }
        })
    }
}
