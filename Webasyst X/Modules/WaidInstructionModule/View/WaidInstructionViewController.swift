//
//  WaidInstructionViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import UIKit
import WebKit

class WaidInstructionViewController: UIViewController {

    var viewModel: WaidInstructionViewModelProtocol!
    
    private var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.dataDetectorTypes = [.all]
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("titleWaidInstruction", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.loadWebSite()
        self.setupLayout()
    }
    
    private func loadWebSite() {
        let url = URL(string: "https://www.webasyst.com/webasyst-id-how-to/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    private func setupLayout() {
        self.view.addSubview(webView)
        NSLayoutConstraint.activate([
            self.webView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.webView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.webView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.webView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }

}
