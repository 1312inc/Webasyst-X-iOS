//
//  InstructionWaid module - InstructionWaidViewConroller.swift
//  Teamwork
//
//  Created by viktkobst on 22/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import SnapKit

final class InstructionWaidViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: InstructionWaidViewModel?
    var coordinator: InstructionWaidCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
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
        
        webView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }

}
