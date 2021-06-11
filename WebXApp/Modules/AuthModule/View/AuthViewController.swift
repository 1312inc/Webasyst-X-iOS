//
//  AuthViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 10.06.2021.
//

import UIKit

class AuthViewController: UIViewController {
    
    var viewModel: AuthViewModel!

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("titlePhone", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("descriptionPhone", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phoneField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.delegate = self
        textField.placeholder = "+7 777 777-77-77"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var regex = try! NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("nextButton", comment: ""), style: .plain, target: self, action: #selector(tappedNext))
        phoneField.becomeFirstResponder()
        self.setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(phoneField)
        view.addSubview(divider)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            phoneField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            phoneField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            divider.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 2),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            divider.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
        ])
    }
    
    private func format(_ phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
        
        guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else {
            return "+"
        }
        
        let range = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")
        
        if number.count > 15 {
            let maxIndex = number.index(number.startIndex, offsetBy: 15)
            number = String(number[number.startIndex ..< maxIndex])
        }
        
        if shouldRemoveLastDigit {
            let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
            number = String(number[number.startIndex ..< maxIndex])
        }
        
        let maxIndex = number.index(number.startIndex, offsetBy: number.count)
        let regRange = number.startIndex ..< maxIndex
        
        if number.count < 7 {
            let pattern = "(\\d)(\\d{3})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3", options: .regularExpression, range: regRange)
        } else {
            let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})(\\d+)"
            number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-$5", options: .regularExpression, range: regRange)
        }
        
        return "+\(number)"
    }
    
    @objc private func tappedNext() {
        viewModel.phoneAuth(phoneField.text ?? "")
    }

}

extension AuthViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullString = (textField.text ?? "") + string
        phoneField.text = format(fullString, shouldRemoveLastDigit: range.length == 1)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        phoneField.text = "+7"
    }
}
