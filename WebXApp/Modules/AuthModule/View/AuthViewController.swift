//
//  AuthViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKUIDelegate {

    //MARK: Data variables
    
    //MARK: Interface elements variable
    private lazy var authWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
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
        let myURL = URL(string:"https://www.webasyst.com/id/oauth2/auth/code")
        let myRequest = URLRequest(url: myURL!)
        authWebView.load(myRequest)
    }
}
