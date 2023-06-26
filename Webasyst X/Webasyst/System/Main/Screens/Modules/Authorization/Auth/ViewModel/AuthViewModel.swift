//
//  AuthViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit
import RxCocoa
import RxSwift
import Webasyst
import libPhoneNumber_iOS

final class AuthViewModel: WebasystViewModelType {
    
    let webasyst = WebasystApp()
    
    public var countryForParsing = ""

    private var phoneInstance: NBPhoneNumberUtil {
        get {
            guard let instance = NBPhoneNumberUtil.sharedInstance() else {
                return NBPhoneNumberUtil.init()
            }
            return instance
        }
    }
    
    struct Input {
        let country: BehaviorRelay<String>
        let send: PublishRelay<String>
    }
    
    let input: Input
    
    struct Output {
        let dataSourceDriver: Driver<Dictionary<String,Int>>
        let phoneCode: Driver<Int>
        let serverStatus: Driver<AuthResult>
        let newCountry: Driver<String>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    
    //MARK: Input Objects
    private let country = BehaviorRelay<String>(value: "")
    private let number = PublishRelay<String>()
    private let send = PublishRelay<String>()
    
    //MARK: Output Objects
    private let dataSource = BehaviorRelay<Dictionary<String,Int>>(value: [:])
    private let phoneCode = PublishRelay<Int>()
    private let newNumber = PublishRelay<String>()
    private let serverStatus = PublishRelay<AuthResult>()
    private let countryName = PublishRelay<String>()
    
    init() {
        //Init input property
        self.input = Input(
            country: country,
            send: send
        )
        
        //Init output property
        self.output = Output(
            dataSourceDriver: dataSource.asDriver(),
            phoneCode: phoneCode.asDriver(onErrorJustReturn: 0),
            serverStatus: serverStatus.asDriver(onErrorJustReturn: .server_error),
            newCountry: countryName.asDriver(onErrorJustReturn: "Invalid country name.")
        )
        
        initDataSource()
        
        if let countryCode = Locale.current.regionCode {
            countryForParsing = countryCode
        }
        
        send.subscribe { [weak self] in
            self?.sendCode($0)
        }.disposed(by: disposeBag)
        
        country.share()
            .subscribe { [weak self] in
                guard let country = $0.element,
                      let selected = self?.dataSource.value[country],
                      let countryCode = self?.phoneInstance.getRegionCode(forCountryCode: NSNumber(value: selected)) else { return }
                self?.countryForParsing = countryCode
                self?.phoneCode.accept(selected)
            }.disposed(by: disposeBag)
        
    }
    
    private func initDataSource() {
        var dictionary = Dictionary<String,Int>()
        NSLocale.isoCountryCodes.forEach { code in
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: Locale.current.identifier).displayName(forKey: NSLocale.Key.identifier, value: id) ?? ""
            guard let country = phoneInstance.getCountryCode(forRegion: code) else { return }
            dictionary[name] = country.intValue
        }
        dataSource.accept(dictionary)
    }
    
    // MARK: - Public functions
    
    public func dropCount() -> Int {
        return phoneInstance.getCountryCode(forRegion: countryForParsing).stringValue.count + 1
    }

    public func extractPhone(_ number: String) -> String {
        if let path = Bundle.main.path(forResource: "mask", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                     let country = jsonResult[countryForParsing] as? String {
                        return format(with: country, phone: number)
                  }
              } catch {
                   return ""
              }
        }
        return number
    }

    public func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex

        let newMask = mask.reduce("", {
            if $1.isNumber {
                return $0 + "#"
            } else if $1 == "(" {
                return $0 + " " + [$1]
            } else if $1 == ")" {
                return $0 + [$1] + " "
            } else {
                return $0 + [$1]
            }
        })

        for ch in newMask where index < numbers.endIndex {
            if ch == "#" {
                result.append(numbers[index])

                index = numbers.index(after: index)

            } else {
                result.append(ch)
            }
        }
        return result
    }

    public func getCountryCode(_ number: String) -> String {
        guard let parsedCountryCode = parser(number)?.countryCode,
              let phone = phoneInstance.getRegionCode(forCountryCode: parsedCountryCode) else { return "" }
        return phone
    }

    public func parser(_ number: String) -> NBPhoneNumber? {
        do {
            let parsedNumber = try phoneInstance.parse(number, defaultRegion: nil)
            return parsedNumber
        } catch {
            return nil
        }
    }
    
    public func validator(_ phone: String) -> Bool {
        let parsed = parser(phone)
        return phoneInstance.isValidNumber(forRegion: parsed, regionCode: countryForParsing)
    }

    public func countryName(countryCode: String) -> String {
        let current = Locale(identifier: Locale.current.identifier)
        guard let countryName = current.localizedString(forRegionCode: countryCode) else { return "" }
        return countryName
    }
    
    // MARK: - Crash when failed number login than try to webview log
    private func sendCode(_ number: String) {
        var newNumber = ""
        for n in number where n.isNumber {
            newNumber.append(n)
        }
        webasyst.getAuthCode(newNumber, type: .phone) { [weak self] authResult in
            self?.serverStatus.accept(authResult)
        }
    }
    
}
