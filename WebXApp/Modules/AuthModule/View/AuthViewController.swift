//
//  AuthViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit
import RxSwift
import WebKit

class AuthViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    //MARK: Data variables
    var viewModel: AuthViewModelProtocol!
    var disposeBag = DisposeBag()
    
    //MARK: Interface elements variable
    private lazy var authWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.dataDetectorTypes = [.all]
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    override func loadView() {
        self.view = authWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
    }
    
    private func loadAuthView() {
        authWebView.load(viewModel.authRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if host.contains("www.webasyst.com") {
                decisionHandler(.allow)
                return
            }
        }
        if navigationAction.request.description.contains("code=")  {
            guard let url = URLComponents(string: navigationAction.request.description) else { return }
            viewModel.successAuth(code: url.queryItems?.first(where: { $0.name == "code" })?.value ?? "", state: url.queryItems?.first(where: { $0.name == "state" })?.value ?? "")
        }
        decisionHandler(.cancel)
    }
}
