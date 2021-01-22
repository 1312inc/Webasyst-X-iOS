//
//  LoaderViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/22/21.
//

import UIKit
import RxSwift
import RxCocoa

class LoaderViewController: UIViewController {

    var viewModel: LoaderViewModelProtocol!
    var disposeBag = DisposeBag()
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.welcomeLabel.text = self.viewModel.userName == "" ? "Добро пожаловать" : "С возвращением,\n\(self.viewModel.userName)"
        fetchData()
    }
    
    // Hide navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Show navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func fetchData() {
        self.viewModel.fetchLoadUserData().bind { event in
            self.progressView.progress += 0.1
            self.progressLabel.text = event.0
        }.disposed(by: disposeBag)
    }

}
