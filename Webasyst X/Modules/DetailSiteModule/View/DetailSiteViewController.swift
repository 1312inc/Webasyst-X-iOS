//
//  DetailSiteViewController.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 25.06.2021.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

class DetailSiteViewController: UIViewController {

    var viewModel: DetailSiteViewModelProtocol!
    private var disposeBag = DisposeBag()
    
    private var textView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bindableViewModel()
        self.viewModel.loadData()
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
    
    private func bindableViewModel() {
        self.viewModel.siteData
            .subscribe(onNext: { result in
                self.setupData(site: result)
            }).disposed(by: disposeBag)
    }
    
    private func setupData(site: DetailSite) {
        self.textView.scrollView.bounces = false
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></HEAD><BODY style=\"background-color: \(UIColor.systemBackground.htmlRGB)\">"
        let htmlEnd = "</BODY></HTML>"
        let text = site.content.replacingOccurrences(of: " style=\"width: 970px;\"", with: "")
        let replacedText = text.replacingOccurrences(of: "<p>", with: "<p style=\"color: \(UIColor.label.htmlRGB)\">")
        let dateFormatter = DateFormatter()
        var somedateString: String = ""
        if site.update_datetime != "" {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myDate = dateFormatter.date(from: site.update_datetime ?? "")!
            dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
            somedateString = dateFormatter.string(from: myDate)
        }
        let fullHTML = "<style type=\"text/css\">" +
            "img {" +
                "max-width: 100%;" +
                "max-height: 100%;" +
            "};" +
            "</style>" +
            "<body id=\"page\">" +
            "<h1 style=\"color: \(UIColor.label.htmlRGB)\">" + site.name + "</h1>" +
            "<span style=\"color: \(UIColor.label.htmlRGB)\">" + somedateString + "</span>" +
            "\(replacedText)</body></html>"
        self.textView.loadHTMLString("\(htmlStart)\(fullHTML.replacingOccurrences(of: "<h2>", with: "<h2 style=\"color: \(UIColor.label.htmlRGB)\">"))\(htmlEnd)", baseURL:  nil)
    }
    
    private func setupLayout() {
        self.view.addSubview(textView)
        NSLayoutConstraint.activate([
            self.textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }

}
