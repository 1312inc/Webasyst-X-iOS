//
//  PayWallViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit
import Webasyst

protocol StoreKitPaywallSuccessful: AnyObject {
    func payConfirmed()
}

final class PayWallViewController: UIViewController {

    //MARK: ViewModel property
    public var viewModel: PayWallViewModel
    public var coordinator: PayWallCoordinator
    public unowned var delegate: StoreKitPaywallSuccessful
    
    public init(viewModel: PayWallViewModel, coordinator: PayWallCoordinator, delegate: StoreKitPaywallSuccessful) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var plan: Plan {
        get {
            self.view().segmentedControl.selectedSegmentIndex == .zero ? .dreamteam : .dreamteamplus
        }
    }
    
    fileprivate var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
    
    func view() -> PayWallView {
        view as! PayWallView
    }
    
    override func loadView() {
        view = PayWallView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .reverseLabel
        view().collectionView.dataSource = self
        view().collectionView.delegate = self
        bindableViewModel()
    }
    
    //MARK: Bindable ViewModel
    private func bindableViewModel() {
        
        view().segmentedControl
            .rx
            .selectedSegmentIndex
            .skip(1)
            .subscribe(onNext: { index in
                var array = self.viewModel.output.dataSource.value
                let localizedString1 = NSLocalizedString("payWallCollectionEmployeeNumber1", comment: "")
                let localizedString2 = NSLocalizedString("payWallCollectionEmployeeNumber2", comment: "")
                let localizedString3 = NSLocalizedString("payWallCollectionDiskNumber1", comment: "")
                let localizedString4 = NSLocalizedString("payWallCollectionDiskNumber2", comment: "")
                let localizedString5 = NSLocalizedString("payWallCollectionHistoryNumber1", comment: "")
                let localizedString6 = NSLocalizedString("payWallCollectionHistoryNumber2", comment: "")
                let products: [SKProduct]
                if index == .zero {
                    array[0] = localizedString1
                    array[3] = localizedString3
                    array[4] = localizedString5
                    products = self.viewModel.output.products.value.prefix(3).asArray()
                } else {
                    array[0] = localizedString2
                    array[3] = localizedString4
                    array[4] = localizedString6
                    products = self.viewModel.output.products.value.suffix(3).asArray()
                }
                self.viewModel.productFormatter(products: products, compl: { [weak self] in
                    self?.view().priceDisplasement(subscribeSet: $0)
                })
                self.viewModel.output.dataSource.accept(array)
                self.view().collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.output.result
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
                self.viewModel.update { [weak self] in
                    self?.delegate.payConfirmed()
                }
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }).disposed(by: disposeBag)
        
        view().termsButton.rx.tap
            .subscribe(onNext: {
                let localized = NSLocalizedString("privatePrivacy", comment: "")
                if let url = URL(string: localized) {
                    UIApplication.shared.open(url)
                }
        }).disposed(by: disposeBag)
        
        view().restoreButton.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                Purchases.standard.restoreCompletion { error in
                    self.coordinator.showAlert(error: error)
                    self.viewModel.update { [weak self] in
                        self?.delegate.payConfirmed()
                    }
                }
        }).disposed(by: disposeBag)
        
        viewModel.output.products
            .observeOn(MainScheduler.asyncInstance)
            .filter { $0.count > .zero }
            .subscribe(onNext: { products in
                self.viewModel.productFormatter(products: products, compl: {
                    self.view().priceDisplasement(subscribeSet: $0)
                })
        }).disposed(by: disposeBag)
        
        view().oneMonthButton.rx.tap
            .subscribe(onNext: {
                self.view().oneMonthButton.loadingIndicator(show: true)
                let product = self.viewModel.output.products.value[0]
                Purchases.standard.purchase(product: product, completion: { state in
                    if state == .purchased {
                        let date = Service.Assistance.extendCurrentDate(value: 1)
                        self.viewModel.extendLicense(type: self.plan, date: date)
                    } else if state == .failed {
                        self.view().oneMonthButton.loadingIndicator(show: false)
                    }
                })
            }).disposed(by: disposeBag)
        
        view().threeMonthsButton.rx.tap
            .subscribe(onNext: {
                self.view().threeMonthsButton.loadingIndicator(show: true, quarterly: true)
                let product = self.viewModel.output.products.value[1]
                Purchases.standard.purchase(product: product, completion: { state in
                    if state == .purchased {
                        let date = Service.Assistance.extendCurrentDate(value: 3)
                        self.viewModel.extendLicense(type: self.plan, date: date)
                    } else if state == .failed {
                        self.view().threeMonthsButton.loadingIndicator(show: false, quarterly: true)
                    }
                })
            }).disposed(by: disposeBag)
        
        view().oneYearButton.rx.tap
            .subscribe(onNext: {
                self.view().oneYearButton.loadingIndicator(show: true)
                let product = self.viewModel.output.products.value[2]
                Purchases.standard.purchase(product: product, completion: { state in
                    if state == .purchased {
                        let date = Service.Assistance.extendCurrentDate(value: 12)
                        self.viewModel.extendLicense(type: self.plan, date: date)
                    } else if state == .failed {
                        self.view().oneYearButton.loadingIndicator(show: false)
                    }
                })
            }).disposed(by: disposeBag)
    }
    
    //MARK: SetupLayout
    private func setupLayout() {
        
    }
    
    //MARK: Navigation methods
}

extension PayWallViewController: UICollectionViewDelegate,
                                 UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.dataSource.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PayWallStaticCell.identifier,
                                                     for: indexPath) as? PayWallStaticCell {
           cell.label.text = viewModel.output.dataSource.value[indexPath.row]
           return cell
       } else {
           return .init()
       }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 180, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))

        if cellCount > 0 {
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing

            let totalCellWidth = cellWidth * cellCount
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - flowLayout.headerReferenceSize.width - flowLayout.footerReferenceSize.width

            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
            }
        }

        return .zero
    }
    
}
