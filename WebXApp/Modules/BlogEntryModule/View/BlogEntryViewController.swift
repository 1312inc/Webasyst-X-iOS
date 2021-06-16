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
        self.setupData()
    }
    
    private func setupData() {
        self.titleLabel.text = self.viewModel.blogEntry.title
        self.textView.scrollView.bounces = false
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        let htmlString = "\(htmlStart)\(self.viewModel.blogEntry.text)\(htmlEnd)"
        self.textView.loadHTMLString(htmlString, baseURL:  nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: self.viewModel.blogEntry.datetime)!
        dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
        let somedateString = dateFormatter.string(from: myDate)
        self.dateLabel.text = somedateString
    }
    
    private func setupLayout() {
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
            self.textView.heightAnchor.constraint(equalToConstant: self.webViewHeight),
            self.textView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
    }
}

extension BlogEntryViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            loadingView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webViewHeight = self.textView.scrollView.contentSize.height
            self.setupLayout()
        }
    }
}
