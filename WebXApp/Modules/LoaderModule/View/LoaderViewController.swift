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
    @IBOutlet weak var commentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        localize()
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
    
    private func localize() {
        self.welcomeLabel.text = self.viewModel.userName == "" ? NSLocalizedString("welcome", comment: "") : "\(NSLocalizedString("welcomeBack", comment: ""))\(self.viewModel.userName)"
        self.commentLabel.text = NSLocalizedString("loaderComment", comment: "")
        self.progressLabel.text = NSLocalizedString("startMessageLoader", comment: "")
    }
    
    private func fetchData() {
        self.viewModel.fetchLoadUserData().bind { event in
            DispatchQueue.main.async {
                self.progressView.progress += 0.1
                self.progressLabel.text = event.0
            }
        }.disposed(by: disposeBag)
    }

}
