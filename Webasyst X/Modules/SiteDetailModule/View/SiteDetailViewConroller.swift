//
//  SiteDetail module - SiteDetailViewConroller.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import Webasyst
import SnapKit

final class SiteDetailViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: SiteDetailViewModel?
    var coordinator: SiteDetailCoordinator?
    
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
        view.backgroundColor = .systemBackground
        self.bindableViewModel()
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
        
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.pageData
            .subscribe(onNext: { result in
                self.setupData(site: result)
            }).disposed(by: disposeBag)
        
        viewModel.output.showLoadingHub
            .subscribe(onNext: { loading in
                if loading {
                    self.setupLoadingView()
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.errorServerRequest
            .subscribe (onNext: { errors in
                switch errors {
                case .permisionDenied:
                    self.setupServerError(with: NSLocalizedString("permisionDenied", comment: ""))
                case .requestFailed(text: let text):
                    self.setupServerError(with: text)
                default:
                    self.setupServerError(with: NSLocalizedString("permisionDenied", comment: ""))
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func setupData(site: DetailSite) {
        view.subviews.forEach({ $0.removeFromSuperview() })
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
        setupLayout()
    }
    
    private func setupLayout() {
        self.view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        
    }

}
