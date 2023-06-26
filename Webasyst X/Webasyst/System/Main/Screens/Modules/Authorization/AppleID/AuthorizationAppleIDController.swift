//
//  AuthorizationAppleIDProvider.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 25.01.2023.
//

import Foundation
import AuthenticationServices
import Webasyst

final class AuthorizationAppleIDController: NSObject {
    
    private let appleIDProvider: ASAuthorizationAppleIDProvider
    
    private let viewController: AuthViewController
    private let completion: (AuthAppleIDData) -> ()
    
    init(viewController: AuthViewController, _ completion: @escaping (AuthAppleIDData) -> ()) {
        
        self.appleIDProvider = ASAuthorizationAppleIDProvider()
        self.viewController = viewController
        self.completion = completion
        
        super.init()
    }
    
    func authorize() {
        
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AuthorizationAppleIDController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            guard let codeData = appleIDCredential.authorizationCode, let authorizationCode = String(data: codeData, encoding: .utf8) else {
                let errorString: String = .getLocalizedString(withKey: "failedGetAppleIDAuthorizationCode")
                viewController.coordinator.showErrorAlert(with: errorString)
                return
            }
            
            guard let identityTokenData = appleIDCredential.identityToken, let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                let errorString: String = .getLocalizedString(withKey: "failedGetAppleIDIdentityToken")
                viewController.coordinator.showErrorAlert(with: errorString)
                return
            }
            
            let authData = AuthAppleIDData(userIdentifier: appleIDCredential.user,
                                           authorizationCode: authorizationCode,
                                           identityToken: identityToken,
                                           isRealUserStatus: appleIDCredential.realUserStatus == .likelyReal ? true : false,
                                           userFirstName: appleIDCredential.fullName?.givenName,
                                           userLastName: appleIDCredential.fullName?.familyName,
                                           userEmail: appleIDCredential.email)
            
            completion(authData)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("\(username) \(password)")
            
        default:
            break
        }
    }
    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        viewController.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: .getLocalizedString(withKey: "faileAppeIDRequest"), errorMessage: error.localizedDescription)
//    }
}

extension AuthorizationAppleIDController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return viewController.view.window!
    }
}
