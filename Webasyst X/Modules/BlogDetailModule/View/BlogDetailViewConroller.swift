//
//  BlogDetail module - BlogDetailViewConroller.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import SnapKit

final class BlogDetailViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: BlogDetailViewModel?
    var coordinator: BlogDetailCoordinator?
    
    private var disposeBag = DisposeBag()
    private var webViewHeight: CGFloat = 0
    
    //Interface element variables
    lazy var textView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
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
        self.bindableViewModel()
    }
    
    private func bindableViewModel() {
        self.textView.scrollView.bounces = false
        
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.postData
            .subscribe(onNext: { [weak self] post in
                guard let self = self else { return }
                let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></HEAD><BODY style=\"background-color: \(UIColor.systemBackground.htmlRGB)\">"
                let htmlEnd = "</BODY></HTML>"
                let text = post.text.replacingOccurrences(of: " style=\"width: 970px;\"", with: "")
                let replacedText = text.replacingOccurrences(of: "<p>", with: "<p style=\"color: \(UIColor.label.htmlRGB)\">")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let myDate = dateFormatter.date(from: post.datetime) ?? Date()
                dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
                let somedateString = dateFormatter.string(from: myDate)
                let fullHTML = "<style type=\"text/css\">" +
                    "img {" +
                        "max-width: 100%;" +
                        "max-height: 100%;" +
                    "};" +
                    "</style>" +
                    "<body id=\"page\">" +
                        "<h1 style=\"color: \(UIColor.label.htmlRGB)\">" + post.title + "</h1>" +
                    "<span style=\"color: \(UIColor.label.htmlRGB)\">" + somedateString + "</span>" +
                    "\(replacedText)</body></html>"
                self.textView.loadHTMLString("\(htmlStart)\(fullHTML)\(htmlEnd)", baseURL: nil)
            }).disposed(by: disposeBag)
        
    }
    
    private func setupLayout() {
        loadingView.removeFromSuperview()
        textView.backgroundColor = UIColor(named: "backgroundColor")
        self.view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }

}
