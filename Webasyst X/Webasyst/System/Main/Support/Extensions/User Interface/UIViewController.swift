//
//  UIViewControllerExtension.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import UIKit

extension UIViewController {
    
    // MARK: - Alerts
    
    func showErrorAlert(withMessage message: String, presenter: UIViewController? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: .getLocalizedString(withKey: "errorTitle"), message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: .getLocalizedString(withKey: "okAlert"), style: .cancel)
            alertController.addAction(alertAction)
            if let presenter = presenter {
                presenter.present(alertController, animated: true, completion: nil)
            } else {
                self.navigationController?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(withTitle title: String = .getLocalizedString(withKey: "errorTitle"), description: String? = nil, errorMessage: String? = nil, tryAgainBlock: Bool = false, analytics: AnalyticsModel? = nil, okCompletionBlock: @escaping () -> () = {}) {
        
        if let analytics = analytics {
            DispatchQueue.global(qos: .background).async {
                let nameOfLog = "errorAlert_\(analytics.type)_\(analytics.method)"
                var parametersOfLog: [String : Any] = [
                    "class": "\(type(of: self))",
                    "method": analytics.method,
                    "type": analytics.type,
                    "title": title,
                    "description": description ?? "nil",
                    "error_message": errorMessage ?? "nil"
                ]
                if analytics.debugInfo.count <= 99 {
                    parametersOfLog["debug_info"] = analytics.debugInfo
                } else {
                    for (i, part) in analytics.debugInfo.split(every: 99).enumerated() {
                        parametersOfLog["debug_info_\(i)"] = part
                    }
                }
                AnalyticsManager.logEvent(nameOfLog, parameters: parametersOfLog)
                let userInfo: [String : Any] = [
                    "parameters": [
                        "class": "\(type(of: self))",
                        "method": analytics.method,
                        "type": analytics.type,
                        "debug_info": analytics.debugInfo
                    ] as [String : Any],
                    "error_description": [
                        "title": title,
                        "description": description ?? "nil",
                        "error_message": errorMessage ?? "nil"
                    ] as [String : Any],
                ]
                AnalyticsManager.logError(domain: "AlertErrorDomain", code: -1000, userInfo: userInfo)
            }
        }
        
        let errorDescription = String.getLocalizedString(withKey: "errorDescription")
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            okCompletionBlock()
        }))
        
        if errorMessage != nil && errorMessage != "" {
            alert.addAction(UIAlertAction(title: errorDescription, style: .default, handler: { _ in
                let title = tryAgainBlock ? String.getLocalizedString(withKey: "tryAgain") : nil
                let errorDescriptionAlertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
                errorDescriptionAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    okCompletionBlock()
                }))
                if let navigationController = self.navigationController {
                    navigationController.present(errorDescriptionAlertController, animated: true, completion: nil)
                } else {
                    self.present(errorDescriptionAlertController, animated: true, completion: nil)
                }
            }))
        }
        
        if let navigationController = navigationController {
            navigationController.present(alert, animated: true, completion: nil)
        } else {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Is there PasscodeLockViewController or another viewController

extension UIViewController {
    
    func isThere<T: UIViewController>(_ type: T.Type) -> Bool {
        
        var isThere = false
        
        switch self {
        case is T:
            isThere = true
        case is UINavigationController:
            isThere = self.isThere(T.self, self as! UINavigationController)
        case is UITabBarController:
            isThere = self.isThere(T.self, self as! UITabBarController)
        default:
            isThere = self.isThere(T.self, self)
        }
        
        return isThere ? true : false
    }
    
    private func isThere<T: UIViewController>(_ type: T.Type, _ navigationController: UINavigationController) -> Bool {
        
        var isThere = false
        
        for viewController in navigationController.viewControllers {
            
            switch viewController {
            case is T:
                isThere = true
            case is UINavigationController:
                isThere = self.isThere(T.self, viewController as! UINavigationController)
            case is UITabBarController:
                isThere = self.isThere(T.self, viewController as! UITabBarController)
            default:
                isThere = self.isThere(T.self, viewController)
            }
            
            if isThere { break }
        }
        
        return isThere ? true : false
    }
    
    private func isThere<T: UIViewController>(_ type: T.Type, _ tabBarController: UITabBarController) -> Bool {
        
        var isThere = false
        
        let presentedViewController = tabBarController.presentedViewController
        switch presentedViewController {
        case is T:
            isThere = true
        case is UINavigationController:
            isThere = self.isThere(T.self, presentedViewController as! UINavigationController)
        case is UITabBarController:
            isThere = self.isThere(T.self, presentedViewController as! UITabBarController)
        default:
            if let presentedViewController = presentedViewController {
                isThere = self.isThere(T.self, presentedViewController)
            }
        }
        
        return isThere ? true : false
    }
    
    private func isThere<T: UIViewController>(_ type: T.Type, _ viewController: UIViewController) -> Bool {
        
        var isThere = false
        
        let presentedViewController = viewController.presentedViewController
        switch presentedViewController {
        case is T:
            isThere = true
        case is UINavigationController:
            isThere = self.isThere(T.self, presentedViewController as! UINavigationController)
        case is UITabBarController:
            isThere = self.isThere(T.self, presentedViewController as! UITabBarController)
        default:
            if let presentedViewController = presentedViewController {
                isThere = self.isThere(T.self, presentedViewController)
            }
        }
        
        return isThere ? true : false
    }
}

// MARK: - Animations

extension UIViewController {
    
    func showViewControllerWith(setRoot: UIWindow, currentRoot: UIViewController) {

        let width = currentRoot.view.frame.size.width
        let height = currentRoot.view.frame.size.height
        let snapShot = setRoot.snapshotView(afterScreenUpdates: true)
        let previousFrame = CGRect(x: width-1, y: 0.0, width: width, height: height)
        let nextFrame = CGRect(x: -width, y: 0.0, width: width, height: height)

        self.view.frame = previousFrame
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            setRoot.addSubview(snapShot!)
            self.view.frame = currentRoot.view.frame
            currentRoot.view.frame = nextFrame
            setRoot.rootViewController = self
        }, completion: { _ in
            snapShot?.removeFromSuperview()
        })
        
    }
    
    func hideViewControllerWith(setRoot: UIWindow, currentRoot: UIViewController) {
        
        let width = currentRoot.view.frame.size.width
        let height = currentRoot.view.frame.size.height
        let snapShot = setRoot.snapshotView(afterScreenUpdates: true)
        let previousFrame = CGRect(x: -width, y: 0.0, width: width, height: height)
        let nextFrame = CGRect(x: width-1, y: 0.0, width: width, height: height)

        self.view.frame = previousFrame
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            setRoot.addSubview(snapShot!)
            self.view.frame = currentRoot.view.frame
            currentRoot.view.frame = nextFrame
            setRoot.rootViewController = self
        }, completion: { _ in
            snapShot?.removeFromSuperview()
        })
        
    }
    
    func dissolveViewControllerWith(setRoot: UIWindow, currentRoot: UIViewController) {
        
        let width = currentRoot.view.frame.size.width
        let height = currentRoot.view.frame.size.height
        let x = currentRoot.view.frame.origin.x
        let y = currentRoot.view.frame.origin.y
        
        let snapShot = setRoot.snapshotView(afterScreenUpdates: true)
        let newFrame = CGRect(x: x - (width / 8), y: y - (height / 8), width: width * 1.25, height: height * 1.25)

        self.view.alpha = 0
        self.view.frame = currentRoot.view.frame
        
        UIView.animate(withDuration: 0.4, animations: {
            setRoot.addSubview(snapShot!)
            snapShot!.alpha = 0
            snapShot!.frame = newFrame
            setRoot.rootViewController = self
            self.view.alpha = 1
        }, completion: { _ in
            snapShot?.removeFromSuperview()
        })
        
    }
    
}
