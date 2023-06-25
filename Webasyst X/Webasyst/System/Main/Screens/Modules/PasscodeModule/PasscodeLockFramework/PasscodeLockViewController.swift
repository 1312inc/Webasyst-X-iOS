//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit
import LocalAuthentication

public class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {
    
    public enum LockState {
        case EnterPasscode
        case SetPasscode
        case ChangePasscode
        case RemovePasscode
        
        func getState() -> PasscodeLockStateType {
            
            switch self {
            case .EnterPasscode: return EnterPasscodeState()
            case .SetPasscode: return SetPasscodeState()
            case .ChangePasscode: return ChangePasscodeState()
            case .RemovePasscode: return EnterPasscodeState(allowCancellation: true)
            }
        }
    }
    
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionEqualHeight: NSLayoutConstraint!
    @IBOutlet public weak var descriptionLabel: UILabel?
    @IBOutlet public var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet public var buttons: [PasscodeSignButton] = [PasscodeSignButton]()
    @IBOutlet public weak var cancelButton: UIButton? {
        didSet {
            cancelButton?.setTitle(.getLocalizedString(withKey: "cancel"), for: .normal)
            cancelButton?.setTitleColor(.systemGray2, for: .normal)
            cancelButton?.setTitleColor(.systemGray2.withAlphaComponent(0.5), for: .highlighted)
        }
    }
    @IBOutlet public weak var deleteSignButton: UIButton? {
        didSet {
            let baseImage = UIImage(systemName: "delete.left.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
            let normalImage = baseImage?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
            let highlightedImage = baseImage?.withTintColor(.systemGray2.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
            deleteSignButton?.setImage(normalImage, for: .normal)
            deleteSignButton?.setImage(highlightedImage, for: .highlighted)
        }
    }
    @IBOutlet public weak var biometricAuthButton: UIButton?
    
    @IBOutlet public weak var placeholdersX: NSLayoutConstraint?
    public var successCallback: ((_ lock: PasscodeLockType) -> Void)?
    public var dismissCompletionCallback: (()->Void)?
    public var animateOnDismiss: Bool
    public var notificationCenter: NotificationCenter?
    
    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal let passcodeInitialState: LockState
    internal var passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true
    
    private var shouldTryToAuthenticateWithBiometrics = true
    
    // MARK: - Initializers
    
    public init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.passcodeInitialState = state
        self.animateOnDismiss = animateOnDismiss
        
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state.getState(), configuration: configuration)
        
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(name: nibName, ofType: "nib")
        
        super.init(nibName: nibName, bundle: bundle)
        
        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        clearEvents()
    }
    
    // MARK: - View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteSignButton?.isEnabled = false
        traitCollectionDidChange(nil)
        
        setupEvents()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        updatePasscodeView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldTryToAuthenticateWithBiometrics && passcodeConfiguration.shouldRequestBiometricAuthImmediately {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                self?.authenticateWithBiometrics()
            })
        }
    }
    
    internal func updatePasscodeView() {
        
        let descriptionText = passcodeLock.state.description
            
        let descriptionTextWidth = descriptionText.width(by: descriptionLabel?.font ?? .adaptiveFont(.body, 15), additionalWidth: 24)
        if self.view.frame.width - descriptionTextWidth <= 0 {
            
            var multiplier = descriptionTextWidth / self.view.frame.width
            let whole = multiplier.whole
            let fraction = multiplier.fraction
            
            if fraction > 0 {
                multiplier = whole + 1
            } else {
                multiplier = whole
            }
            
            descriptionEqualHeight = descriptionEqualHeight.changeConstraint(withMultiplier: multiplier)
        }
        
        titleLabel?.text = passcodeLock.state.title
        descriptionLabel?.text = descriptionText
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
        deleteSignButton?.isHidden = passcodeLock.isBiometricAuthAllowed
        biometricAuthButton?.isHidden = !passcodeLock.isBiometricAuthAllowed
        
        if passcodeLock.isBiometricAuthAllowed {
            let context = LAContext()
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return
            }
            switch context.biometryType {
            case .none:
                biometricAuthButton?.isHidden = true
            case .touchID:
                let baseImage = UIImage(systemName: "touchid")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 32))
                let normalImage = baseImage?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
                let highlightedImage = baseImage?.withTintColor(.systemGray2.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
                biometricAuthButton?.setImage(normalImage, for: .normal)
                biometricAuthButton?.setImage(highlightedImage, for: .highlighted)
            case .faceID:
                let baseImage = UIImage(systemName: "faceid")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 32))
                let normalImage = baseImage?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
                let highlightedImage = baseImage?.withTintColor(.systemGray2.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
                biometricAuthButton?.setImage(normalImage, for: .normal)
                biometricAuthButton?.setImage(highlightedImage, for: .highlighted)
            @unknown default:
                preconditionFailure("Unknown biometry type")
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        for button in buttons {
            button.traitCollectionDidChange()
        }
        
        for placeholder in placeholders {
            placeholder.traitCollectionDidChange()
        }
    }
    
    // MARK: - Events
    
    private func setupEvents() {
        
        notificationCenter?.addObserver(self, selector: #selector(appWillEnterForegroundHandler), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(appDidEnterBackgroundHandler), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func clearEvents() {
        
        notificationCenter?.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter?.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc public func appWillEnterForegroundHandler(notification: NSNotification) {
        
        if !shouldTryToAuthenticateWithBiometrics && passcodeConfiguration.shouldRequestBiometricAuthImmediately {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                self?.authenticateWithBiometrics()
            })
        }
    }
    
    @objc public func appDidEnterBackgroundHandler(notification: NSNotification) {
        
        UserDefaults.setBiometricAuthInProgress(false)
        shouldTryToAuthenticateWithBiometrics = false
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        
        guard isPlaceholdersAnimationCompleted else { return }
        
        passcodeLock.addSign(sign: sender.passcodeSign)
        
        if !passcodeLock.passcodeIsEmpty && passcodeLock.isBiometricAuthAllowed {
            biometricAuthButton?.isHidden = true
            deleteSignButton?.isHidden = false
        }
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        
        dismissPasscodeLock(lock: passcodeLock)
    }
    
    @IBAction func deleteSignButtonTap(_ sender: UIButton) {
        
        passcodeLock.removeSign()
        
        if passcodeLock.passcodeIsEmpty && passcodeLock.isBiometricAuthAllowed {
            biometricAuthButton?.isHidden = false
            deleteSignButton?.isHidden = true
        }
    }
    
    
    @IBAction func biometricAuthButton(_ sender: Any) {
        
        Vibration.rigid.vibrate()
        
        passcodeLock.authenticateWithBiometrics()
    }
    private func authenticateWithBiometrics() {
        
        guard passcodeConfiguration.repository.hasPasscode else { return }
        
        if passcodeLock.isBiometricAuthAllowed && UserDefaults.passcodeCheckIsNeeded() {
            
            UserDefaults.setBiometricAuthInProgress(true)
            
            passcodeLock.authenticateWithBiometrics()
        }
    }
    
    internal func dismissPasscodeLock(lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {
        
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            
            dismiss(animated: animateOnDismiss) { [weak self] in
                guard let self = self else { return }
                self.dismissCompletionCallback?()
                completionHandler?()
            }
            
            return
            
        // if pushed in a navigation controller
        } else if navigationController != nil {
        
            navigationController?.popViewController(animated: animateOnDismiss)
        }
        
        dismissCompletionCallback?()
        
        completionHandler?()
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {
        
        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false
        
        animatePlaceholders(placeholders: placeholders, toState: .Error)
        
        placeholdersX?.constant = -20
        view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: { [weak self] in
            guard let self = self else { return }
                
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: { [weak self] completed in
                guard let self = self else { return }
                
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(placeholders: self.placeholders, toState: .Inactive)
        })
    }
    
    internal func animatePlaceholders(placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        
        for placeholder in placeholders {
            
            placeholder.animateState(state: state)
        }
    }
    
    private func animatePlacehodlerAtIndex(index: Int, toState state: PasscodeSignPlaceholderView.State) {
        
        guard index < placeholders.count && index >= 0 else { return }
        
        placeholders[index].animateState(state: state, lastSign: index == placeholders.count - 1)
    }

    // MARK: - PasscodeLockDelegate
    
    public func passcodeLockDidSucceed(lock: PasscodeLockType) {
        
        Vibration.success.vibrate()
        
        deleteSignButton?.isEnabled = false
        
        for button in buttons {
            button.isEnabled = false
        }
        
        animatePlaceholders(placeholders: placeholders, toState: .Success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            
            if self.passcodeInitialState == .EnterPasscode {
                self.successCallback?(lock)
                self.notificationCenter?.post(name: .passcodeLockDidSucceed, object: nil)
            } else {
                self.dismissPasscodeLock(lock: lock, completionHandler: { [weak self] in
                    self?.successCallback?(lock)
                    self?.notificationCenter?.post(name: .passcodeLockDidSucceed, object: nil)
                })
            }
        })
    }
    
    public func passcodeLockDidFail(lock: PasscodeLockType) {
        
        Vibration.error.vibrate()
        
        if biometricAuthButton?.currentImage != nil {
            biometricAuthButton?.isHidden = false
            deleteSignButton?.isHidden = true
        }
        animateWrongPassword()
    }
    
    public func passcodeLockDidChangeState(lock: PasscodeLockType) {
        
        Vibration.light.vibrate()
        
        animatePlaceholders(placeholders: placeholders, toState: .DidChange)
        
        self.updatePasscodeView()
        self.deleteSignButton?.isEnabled = false
    }
    
    public func passcodeLock(lock: PasscodeLockType, addedSignAtIndex index: Int) {
        
        if index < placeholders.count - 1 {
            Vibration.light.vibrate()
        }
        
        animatePlacehodlerAtIndex(index: index, toState: .Active)
        deleteSignButton?.isEnabled = true
    }
    
    public func passcodeLock(lock: PasscodeLockType, removedSignAtIndex index: Int) {
        
        Vibration.light.vibrate()
        
        animatePlacehodlerAtIndex(index: index, toState: .Inactive)
        
        if index == 0 {
            
            deleteSignButton?.isEnabled = false
        }
    }
}
