//
//  QRViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.01.2023.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class QRViewController: UIViewController {
    
    //MARK: ViewModel property
    var viewModel: QRViewModel
    var coordinator: QRCoordinator
    var type: QRCoordinator.QRType
    
    fileprivate var disposeBag = DisposeBag()
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrBorderScaled: Bool? = false
    var timer: Timer?
    
    // MARK: - UI elements
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var qrDescription: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = .getLocalizedString(withKey: "QRDescription")
        label.font = .adaptiveFont(.body, 13)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        view.layer.cornerRadius = 16
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var qrFrameDescription: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = .getLocalizedString(withKey: "QRFrameDescription")
        label.font = .adaptiveFont(.body, 13)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
        }
        
        view.layer.cornerRadius = 16
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
        return view
    }()
    
    private lazy var qrBorder: UIImageView = {
        let image = UIImage(named: "QRBorder")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.color = .white
        loadingView.backgroundColor = .black.withAlphaComponent(0.7)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()
    
    // MARK: - Init
    
    init(viewModel: QRViewModel, coordinator: QRCoordinator, type: QRCoordinator.QRType) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.type = type
        super.init(nibName: nil, bundle: nil)
        bindableViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.qrBorderScaled = nil
        self.qrBorder.layer.removeAllAnimations()
        self.captureSession = nil
        self.previewLayer = nil
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureConfigure()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.input.code.value == "" {
            reloadSesson()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        qrDescription.layer.cornerRadius = qrDescription.frame.height / 4
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
        if qrBorderScaled != nil {
            qrBorderScaled = nil
            qrBorder.layer.removeAllAnimations()
            self.qrBorder.transform = .identity
        }
    }
    
    public func reloadSesson() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
        if qrBorderScaled == nil {
            qrBorderScaled = true
            qrBorderAnimate()
        }
        if qrBorder.constraints.isEmpty {
            qrBorder.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                qrBorder.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
                qrBorder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                qrBorder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }
    }
    
    private func bindableViewModel() {
        
        viewModel.input.code
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .skip(1)
            .do(onNext: { [weak self] _ in
                self?.loadingView.startAnimating()
            })
            .subscribe(onNext: { [weak self] code in
                self?.viewModel.input.sendCode.onNext(code)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.codeResult
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .subscribe(onNext: { [weak self] status in
                
                guard let self = self else { return }
                
                switch status {
                case .success:
                    self.coordinator.successAuth()
                case .no_channels:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "phoneError"), presenter: self)
                case .invalid_client:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "clientIdError"), presenter: self)
                case .require_code_challenge:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "codeChalengeError"), presenter: self)
                case .invalid_email:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "emailError"), presenter: self)
                case .invalid_phone:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "phoneError"), presenter: self)
                case .request_timeout_limit:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "requestTimeoutLimit"), presenter: self)
                case .sent_notification_fail:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "sentNotificationFail"), presenter: self)
                case .server_error:
                    self.coordinator.showErrorAlert(with: .getLocalizedString(withKey: "sentNotificationFail"), presenter: self)
                case .undefined(error: let error):
                    self.coordinator.showErrorAlert(with: error, presenter: self)
                }
                
                switch status {
                case .success:
                    break
                default:
                    DispatchQueue.main.async {
                        self.loadingView.stopAnimating()
                    }
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.title = .getLocalizedString(withKey: "QRTopLabel")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.adaptiveFont(.body, 17, .semibold)]
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
      }
    
    private func layout() {
        view.backgroundColor = .black
        
        setupNavigationBar()
        
        view.addSubview(topView)
        view.addSubview(qrDescription)
        view.addSubview(qrBorder)
        view.addSubview(loadingView)
        view.addSubview(qrFrameDescription)
        
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: self.navigationController!.navigationBar.frame.height),
            qrDescription.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -32),
            qrDescription.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            qrDescription.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            qrBorder.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            qrBorder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            qrBorder.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            qrFrameDescription.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            qrFrameDescription.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            qrFrameDescription.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            loadingView.widthAnchor.constraint(equalToConstant: loadingView.frame.width + 64),
            loadingView.heightAnchor.constraint(equalToConstant: loadingView.frame.height + 64),
            loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        qrBorderAnimate()
        
        view.layoutIfNeeded()
        
        loadingView.layer.cornerRadius = loadingView.frame.height / 8
    }
    
    private func qrBorderAnimate() {
        
        guard let qrBorderScaled = qrBorderScaled else { return }
        
        UIView.animate(withDuration: 0.6, animations: {
            switch qrBorderScaled {
            case true:
                self.qrBorder.transform =  CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            case false:
                self.qrBorder.transform =  CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
        }) { _ in
            self.qrBorderScaled?.toggle()
            self.qrBorderAnimate()
        }
    }
}

// MARK: - Actions

extension QRViewController {
    
    @objc private func close() {
        dismiss(animated: true)
    }
}

// MARK: - AVCapture

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    private func captureConfigure() {
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if qrBorderScaled != nil, metadataObjects != [], let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
            
            if metadataObject.type == AVMetadataObject.ObjectType.qr {
                
                guard let code = metadataObject.stringValue else { return }
                
                let wrongCodeCompletion: (String) -> () = { text in
                    
                    (self.qrFrameDescription.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text = text

                    let resetTimer = { [weak self] in
                        guard let self = self else { return }
                        if self.timer?.isValid ?? false {
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] value in
                            guard let self = self else { return }
                            UIView.animate(withDuration: 0.3) {
                                self.qrFrameDescription.alpha = 0
                            }
                        })
                    }
                    if self.qrFrameDescription.alpha != 1 {
                        self.qrFrameDescription.layer.removeAllAnimations()
                        UIView.animate(withDuration: 0.3) {
                            self.qrFrameDescription.alpha = 1
                        } completion: { _ in
                            resetTimer()
                        }
                    } else {
                        resetTimer()
                    }
                }
                
                let authTrigger = "WEBASYSTID-SIGNIN"
                let linkTrigger = "WEBASYSTID-ADDACCOUNT"
                
                if code.contains(authTrigger) || code.contains(linkTrigger) {
                    
                    let stopCaptureSessionClosure: () -> () = {
                        
                        self.qrFrameDescription.alpha = 0
                        
                        if self.qrBorderScaled != nil {
                            self.qrBorderScaled = nil
                            self.qrBorder.layer.removeAllAnimations()
                            self.qrBorder.transform = .identity
                            self.view.constraints.forEach { constraint in
                                if constraint.firstItem as? NSObject == self.qrBorder || constraint.secondItem as? NSObject == self.qrBorder {
                                    constraint.isActive = false
                                }
                            }
                            self.qrBorder.translatesAutoresizingMaskIntoConstraints = true
                        }
                        
                        let barCodeObject = self.previewLayer.transformedMetadataObject(for: metadataObject)!
                        let bounds = barCodeObject.bounds
                        let value = bounds.size.width
                        
                        self.qrBorder.frame = CGRect(x: bounds.origin.x - (value * 0.3 / 2),
                                                y: bounds.origin.y - (value * 0.3 / 2),
                                                width: bounds.size.width + (value * 0.3),
                                                height: bounds.size.height + (value * 0.3))
                        
                        Vibration.light.vibrate()
                        
                        DispatchQueue.global(qos: .background).async {
                            self.captureSession.stopRunning()
                        }
                    }
                    
                    if type == .auth {
                        if code.contains(authTrigger) {
                            stopCaptureSessionClosure()
                            viewModel.input.code.accept(code)
                        } else {
                            if let domain = code.components(separatedBy: "?").last?.removingPercentEncoding {
                                stopCaptureSessionClosure()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
                                    guard let self = self else { return }
                                    self.coordinator.openExpressAuthScreen(self, domain: domain, code: code)
                                })
                            }
                        }
                    } else {
                        if code.contains(linkTrigger) {
                            if let completion = coordinator.completion {
                                stopCaptureSessionClosure()
                                loadingView.startAnimating()
                                completion(code)
                            }
                        } else {
                            wrongCodeCompletion(.getLocalizedString(withKey: "QRFrameWrongTriggerDescriptionWithoutUsername"))
                        }
                    }
                } else {
                    let text = String.getLocalizedString(withKey: "QRFrameDescription")
                    wrongCodeCompletion(text)
                }
            }
        }
    }
}
