//
//  InstallView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 29.11.2022.
//

import UIKit
import Webasyst

protocol InstallDelegate: UIViewController {
    func install(_ closure: @escaping (InstallView.InstallResult) -> ())
}

@objc protocol InstallProtocol: ViewProtocol {}

class InstallView: UIView, InstallProtocol, UIDeviceShared {
    
    enum InstallResult {
        case checkLicense(Result)
        case checkInstallApp(Result)
        case completed
        
        enum Result {
            case success
            case error
        }
    }
    
    weak var delegate: InstallDelegate?
    
    private var fastProgressBlock: (() -> ())?
    private var progressTimer: Timer?
    private var timeLimitTimer: Timer?
    
    init(install: UserInstall) {
        super.init(frame: .zero)
        guard let name = install.name, let data = install.image else { return }
        self.installImage.image = .init(data: data)
        if let logo = install.imageLogo, !logo {
            self.installLabel.text = install.logoText
        }
        let buttonInstall: String = .getLocalizedString(withKey: "buttonInstall")
        let titleInstall: String = .getLocalizedString(withKey: "titleInstall")
        let appName: String = .appName
        let replacedInstall = buttonInstall.replacingOccurrences(of: "%APPNAME%", with: appName)
        let replacedTasksFirst = titleInstall.replacingOccurrences(of: "%APPNAME%", with: appName)
        let replacedTasksOrigin = replacedTasksFirst.replacingOccurrences(of: "%ACCOUNTNAME%", with: install.domain)
        let description: String = .getLocalizedString(withKey: "descriptionInstall")
        let replacedDescriptionFirst = description.replacingOccurrences(of: "%APPNAME%", with: appName)
        let replacedDescriptionOrigin = replacedDescriptionFirst.replacingOccurrences(of: "%ACCOUNTNAME%", with: name)
        self.descriptionLabel.text = replacedDescriptionOrigin
        self.titleLabel.text = replacedTasksOrigin
        installButton.setTitle(replacedInstall, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    fileprivate let installImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        return imageView
    }()
    
    fileprivate let installLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50, weight: .bold)
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let staticImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(named: "installIcon")
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate let staticMagicWandImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(named: "stick")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate let arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "arrow.right")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        var label = UILabel()
        label.font = .adaptiveFont(.title2, 22, .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Install view
    fileprivate let installView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var installButton: UIButton = {
        var button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.footnote, 15, .bold)
        button.backgroundColor = .appColor
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 12.5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(installer), for: .touchUpInside)
        return button
    }()
    
    fileprivate let freeLabel: UILabel = {
        var label = UILabel()
        label.font = .adaptiveFont(.subheadline, 15, .bold)
        label.text = .getLocalizedString(withKey: "freeInstall")
        label.textColor = .systemGreen
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.alpha = 0
        view.progress = 0.05
        view.clipsToBounds = true
        view.trackTintColor = .systemGray4
        view.progressTintColor = .appColor
        view.layer.cornerRadius = 12.5
        return view
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        var label = UILabel()
        label.font = .adaptiveFont(.footnote, 13)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let contentView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        
        backgroundColor = .reverseLabel
        parentViewController?.navigationController?.navigationBar.prefersLargeTitles = false
        parentViewController?.navigationController?.appearanceColor(color: .reverseLabel)
        
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(installImage)
        installImage.addSubview(installLabel)
        contentView.addSubview(staticImage)
        contentView.addSubview(arrowImage)
        contentView.addSubview(staticMagicWandImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(installView)
        installView.addSubview(progressView)
        installView.addSubview(installButton)
        installView.addSubview(freeLabel)
        contentView.addSubview(descriptionLabel)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(scrollView.snp.height)
            make.width.equalToSuperview()
        }

        let offset = (self.frame.width - (self.frame.width * 0.8)) / 2
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalToSuperview().offset(offset)
            make.right.equalToSuperview().inset(offset)
        }

        installImage.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.trailing.lessThanOrEqualToSuperview().inset(offset)
            make.width.equalTo(staticImage.snp.width)
            make.height.equalTo(installImage.snp.width)
        }
        
        installLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        staticImage.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.greaterThanOrEqualToSuperview().offset(offset)
            make.width.lessThanOrEqualTo(120)
            make.height.equalTo(staticImage.snp.width)
        }

        arrowImage.snp.makeConstraints { make in
            make.leading.equalTo(staticImage.snp.trailing).offset(15)
            make.trailing.equalTo(installImage.snp.leading).offset(-15)
            make.width.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(staticImage.snp.centerY)
        }
        
        installView.snp.makeConstraints { make in
            make.top.equalTo(installImage.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualTo(descriptionLabel.snp.top).offset(-24)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
        
        installButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
        
        freeLabel.snp.makeConstraints { make in
            make.top.equalTo(installButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.bottom.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().inset(offset)
        }
        
        staticMagicWandImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.bottom.equalToSuperview().inset(32)
            make.height.width.equalTo(48)
        }
        
        layoutIfNeeded()
        
        staticImage.layer.cornerRadius = staticImage.frame.width / 2
        installImage.layer.cornerRadius = installImage.frame.width / 2
    }
    
    @objc func installer() {
        startInstall()
        delegate?.install { [weak self] resultValue in
            guard let self = self else { return }
            switch resultValue {
            case .checkLicense(let result):
                switch result {
                case .success:
                    if progressView.progress < 0.2 {
                        self.fastProgressBlock = { [weak self] in
                            guard let self = self else { return }
                            if self.progressView.progress >= 0.2 {
                                self.fastProgressBlock = nil
                            }
                        }
                    }
                case .error:
                    self.failedOnboarding()
                }
            case .checkInstallApp(let result):
                switch result {
                case .success:
                    if progressView.progress < 0.5 {
                        self.fastProgressBlock = { [weak self] in
                            guard let self = self else { return }
                            if self.progressView.progress >= 0.5 {
                                self.fastProgressBlock = nil
                            }
                        }
                    }
                case .error:
                    self.failedOnboarding()
                }
            case .completed:
                self.doneProgressTimer()
            }
        }
    }
}

// MARK: - Progress

extension InstallView {
    
    // MARK: - Animation
    
    private func startInstall() {
        
        freeLabel.alpha = 0.2
        freeLabel.text = .getLocalizedString(withKey: "installProgressDescription")
        freeLabel.textColor = .systemGray2
        freeLabel.font = .adaptiveFont(.subheadline, 15, .regular)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            installButton.snp.updateConstraints { make in
                make.height.equalTo(4)
            }
            installButton.alpha = 0
            
            progressView.snp.updateConstraints { make in
                make.height.equalTo(4)
            }
            progressView.alpha = 1
            progressView.layer.cornerRadius = 2
            
            freeLabel.alpha = 1
            
            layoutIfNeeded()
        } completion: { [weak self] successed in
            guard let self = self else { return }
            if !successed {
                self.installButton.snp.updateConstraints { make in
                    make.height.equalTo(4)
                }
                self.installButton.alpha = 0
                
                self.progressView.snp.updateConstraints { make in
                    make.height.equalTo(4)
                }
                self.progressView.alpha = 1
                self.progressView.layer.cornerRadius = 2
                
                self.freeLabel.alpha = 1
                
                self.layoutIfNeeded()
            }
            self.startTimeLimitTimer()
            self.startProgressTimer()
        }
    }
    
    private func stopInstall() {
        
        freeLabel.alpha = 0.2
        freeLabel.text = .getLocalizedString(withKey: "freeInstall")
        freeLabel.textColor = .systemGreen
        freeLabel.font = .adaptiveFont(.subheadline, 15, .bold)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            installButton.snp.updateConstraints { make in
                make.height.equalTo(50)
            }
            installButton.alpha = 1
            
            progressView.snp.updateConstraints { make in
                make.height.equalTo(50)
            }
            progressView.alpha = 0
            progressView.layer.cornerRadius = 12.5
            
            freeLabel.alpha = 1
            
            layoutIfNeeded()
        } completion: { [weak self] successed in
            guard let self = self else { return }
            if !successed {
                self.installButton.snp.updateConstraints { make in
                    make.height.equalTo(50)
                }
                self.installButton.alpha = 1
                
                self.progressView.snp.updateConstraints { make in
                    make.height.equalTo(50)
                }
                self.progressView.alpha = 0
                self.progressView.layer.cornerRadius = 12.5
                
                self.freeLabel.alpha = 1
                
                self.layoutIfNeeded()
            }
            self.progressView.trackTintColor = .systemGray4
        }
    }
    
    // MARK: - Timers
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerBlock(_:)), userInfo: nil, repeats: true)
    }
    
    @objc
    private func timerBlock(_ timer: Timer) {
        if progressView.progress < 0.9 {
            let additionalValue: Float = 0.00015
            progressView.progress += fastProgressBlock != nil ? additionalValue * 3 : additionalValue
            fastProgressBlock?()
        } else {
            timer.invalidate()
            progressTimer = nil
        }
    }
    
    private func startTimeLimitTimer() {
        
        timeLimitTimer = Timer.scheduledTimer(withTimeInterval: 90, repeats: false, block: { [weak self] timer in
            guard let self = self else { return }
            
            delegate?.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: .getLocalizedString(withKey: "installTimeLimit"), analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "installTimeLimit"))
            self.failedOnboarding()
            timer.invalidate()
            self.timeLimitTimer = nil
        })
    }
    
    // MARK: - Status
    
    func doneProgressTimer() {
        
        progressTimer?.invalidate()
        progressTimer = nil
        timeLimitTimer?.invalidate()
        timeLimitTimer = nil
        
        progressView.setProgress(1, animated: true)
    }
    
    func failedOnboarding() {
        
        progressTimer?.invalidate()
        progressTimer = nil
        timeLimitTimer?.invalidate()
        timeLimitTimer = nil
        
        progressView.progress = 0
        progressView.trackTintColor = .systemRed
        freeLabel.text = .getLocalizedString(withKey: "errorTitle")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let self = self else { return }
            self.stopInstall()
        })
    }
}

