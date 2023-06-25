//
//  PayWallView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import UIKit
import SnapKit

enum State {
    case hide
    case show
}

class PayWallView: UIView, UIDeviceShared {
    
    var state: State = .hide
    
    fileprivate var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    fileprivate var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    public var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .systemGray6
        segmentedControl.addTarget(self, action: #selector(plusManager), for: .valueChanged)
        return segmentedControl
    }()
    
    fileprivate var imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Group")
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate var topTextLabel: UILabel = {
        let topTextLabel = UILabel()
        let localizedString = NSLocalizedString("payWallHeadline", comment: "")
        topTextLabel.font = .adaptiveFont(.title2, 24, .bold)
        topTextLabel.text = localizedString
        topTextLabel.numberOfLines = .zero
        topTextLabel.translatesAutoresizingMaskIntoConstraints = false
        topTextLabel.textAlignment = .center
        return topTextLabel
    }()
    
    fileprivate lazy var extendedTextLabel: UILabel = {
        let extendedTextLabel = UILabel()
        let localizedString = NSLocalizedString("payWallExtendTitle", comment: "")
        extendedTextLabel.font = .adaptiveFont(.subheadline, 15, .semibold)
        extendedTextLabel.text = localizedString
        extendedTextLabel.numberOfLines = .zero
        extendedTextLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        extendedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        extendedTextLabel.textAlignment = .center
        extendedTextLabel.alpha = .zero
        return extendedTextLabel
    }()
    
    fileprivate lazy var extendedDescriptionTextLabel: UILabel = {
        let extendedDescriptionTextLabel = UILabel()
        let localizedString = NSLocalizedString("payWallExtendDescription", comment: "")
        extendedDescriptionTextLabel.font = .adaptiveFont(.caption1, 12)
        extendedDescriptionTextLabel.text = localizedString
        extendedDescriptionTextLabel.numberOfLines = .zero
        extendedDescriptionTextLabel.translatesAutoresizingMaskIntoConstraints = false
        extendedDescriptionTextLabel.textAlignment = .center
        extendedDescriptionTextLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        extendedDescriptionTextLabel.alpha = .zero
        return extendedDescriptionTextLabel
    }()
    
    fileprivate var semiDescriptionLabel: UILabel = {
        let semiDescriptionLabel = UILabel()
        let localizedString = NSLocalizedString("payWallSemiDescription", comment: "")
        semiDescriptionLabel.font = .adaptiveFont(.footnote, 15)
        semiDescriptionLabel.text = localizedString
        semiDescriptionLabel.numberOfLines = .zero
        semiDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        semiDescriptionLabel.textAlignment = .center
        semiDescriptionLabel.textColor = .systemGray
        return semiDescriptionLabel
    }()
    
    public var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .reverseLabel
        collectionView.isScrollEnabled = false
        collectionView.register(PayWallStaticCell.self, forCellWithReuseIdentifier: PayWallStaticCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    fileprivate var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    fileprivate var maskBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .reverseLabel
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    fileprivate var maskAnimatedBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .reverseLabel
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.alpha = .zero
        return backgroundView
    }()
    
    fileprivate var circleView: UIImageView = {
        let circleView = UIImageView()
        let configuration = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(systemName: "star.fill", withConfiguration: configuration)
        let imageWithTintColor = image?.withRenderingMode(.alwaysTemplate)
        circleView.image = image
        circleView.tintColor = .white
        circleView.backgroundColor = .systemRed
        circleView.contentMode = .center
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = 12.5
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    
    fileprivate var cashFlowImage: UIImageView = {
        let circleView = UIImageView()
        let configuration = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(named: "cashFlow")
        circleView.image = image
        circleView.contentMode = .center
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = 12.5
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    
    fileprivate var unknownImage: UIImageView = {
        let circleView = UIImageView()
        let configuration = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(named: "image10")
        circleView.image = image
        circleView.contentMode = .center
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = 12.5
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    
    fileprivate var monthsFreeLabel: UILabel = {
        let monthsFreeLabel = UILabel()
        let localizedString = NSLocalizedString("payWallFree", comment: "")
        monthsFreeLabel.text = localizedString
        monthsFreeLabel.textColor = .systemRed
        monthsFreeLabel.font = .adaptiveFont(.title2, 21, .bold)
        monthsFreeLabel.translatesAutoresizingMaskIntoConstraints = false
        monthsFreeLabel.textAlignment = .center
        return monthsFreeLabel
    }()
    
    public var threeMonthsButton: UIButton = {
        let threeMonthsButton = UIButton()
        let localizedString = NSLocalizedString("payWall3MonthsButtonText", comment: "")
        threeMonthsButton.setTitle(localizedString, for: .normal)
        threeMonthsButton.titleLabel?.font = .adaptiveFont(.subheadline, 16, .semibold)
        threeMonthsButton.translatesAutoresizingMaskIntoConstraints = false
        threeMonthsButton.contentHorizontalAlignment = .center
        threeMonthsButton.backgroundColor = .systemPink
        threeMonthsButton.layer.cornerRadius = 10
        threeMonthsButton.layer.masksToBounds = true
        return threeMonthsButton
    }()
    
    fileprivate lazy var descriptionThreeMonthLabel: UILabel = {
        let descriptionThreeMonthLabel = UILabel()
        let localizedString = NSLocalizedString("payWall3MonthsDescription", comment: "")
        descriptionThreeMonthLabel.font = .adaptiveFont(.footnote, 14)
        descriptionThreeMonthLabel.text = localizedString
        descriptionThreeMonthLabel.numberOfLines = .zero
        descriptionThreeMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionThreeMonthLabel.textAlignment = .center
        descriptionThreeMonthLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        return descriptionThreeMonthLabel
    }()
        
    public var oneMonthButton: UIButton = {
        let oneMonthButton = UIButton()
        let localizedString = NSLocalizedString("payWall1MonthsButtonText", comment: "")
        oneMonthButton.setTitle(localizedString, for: .normal)
        oneMonthButton.titleLabel?.font = .adaptiveFont(.subheadline, 16, .semibold)
        oneMonthButton.translatesAutoresizingMaskIntoConstraints = false
        oneMonthButton.contentHorizontalAlignment = .center
        oneMonthButton.backgroundColor = .systemBlue
        oneMonthButton.layer.cornerRadius = 10
        oneMonthButton.layer.masksToBounds = true
        return oneMonthButton
    }()
    
    fileprivate lazy var descriptionOneMonthLabel: UILabel = {
        let descriptionOneMonthLabel = UILabel()
        let localizedString = NSLocalizedString("payWall1MonthDescription", comment: "")
        descriptionOneMonthLabel.font = .adaptiveFont(.footnote, 14)
        descriptionOneMonthLabel.text = localizedString
        descriptionOneMonthLabel.numberOfLines = .zero
        descriptionOneMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionOneMonthLabel.textAlignment = .center
        descriptionOneMonthLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        return descriptionOneMonthLabel
    }()
    
    public var oneYearButton: UIButton = {
        let oneYearButton = UIButton()
        let localizedString = NSLocalizedString("payWall1YearButtonText", comment: "")
        oneYearButton.setTitle(localizedString, for: .normal)
        oneYearButton.titleLabel?.font = .adaptiveFont(.subheadline, 16, .semibold)
        oneYearButton.translatesAutoresizingMaskIntoConstraints = false
        oneYearButton.contentHorizontalAlignment = .center
        oneYearButton.backgroundColor = .systemBlue
        oneYearButton.layer.cornerRadius = 10
        oneYearButton.layer.masksToBounds = true
        return oneYearButton
    }()
    
    fileprivate lazy var descriptionOneYearLabel: UILabel = {
        let descriptionOneYearLabel = UILabel()
        let localizedString = NSLocalizedString("payWall1YearDescription", comment: "")
        descriptionOneYearLabel.font = .adaptiveFont(.footnote, 14)
        descriptionOneYearLabel.text = localizedString
        descriptionOneYearLabel.numberOfLines = .zero
        descriptionOneYearLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        descriptionOneYearLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionOneYearLabel.textAlignment = .center
        return descriptionOneYearLabel
    }()
    
    fileprivate var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        let localizedString = NSLocalizedString("payWallRegulations", comment: "")
        descriptionLabel.font = .adaptiveFont(.caption2, 13)
        descriptionLabel.text = localizedString
        descriptionLabel.numberOfLines = .zero
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .systemGray2
        return descriptionLabel
    }()
    
    public var termsButton: UIButton = {
        let termsButton = UIButton()
        let localizedString = NSLocalizedString("termsAndPrivacy", comment: "")
        termsButton.setTitle(localizedString, for: .normal)
        termsButton.setTitleColor(.systemBlue, for: .normal)
        termsButton.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.contentHorizontalAlignment = .center
        return termsButton
    }()
    
    public var restoreButton: UIButton = {
        let termsButton = UIButton()
        let localizedString = NSLocalizedString("payWallRestore", comment: "")
        termsButton.setTitle(localizedString, for: .normal)
        termsButton.setTitleColor(.systemBlue, for: .normal)
        termsButton.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.contentHorizontalAlignment = .center
        return termsButton
    }()
    
    fileprivate var extendedBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        DispatchQueue.main.async {
            let localizedString1 = NSLocalizedString("payWallCollectionEmployeeNumber1", comment: "")
            let localizedString2 = NSLocalizedString("payWallCollectionEmployeeNumber2", comment: "")
            self.segmentedControl.insertSegment(withTitle: localizedString1, at: 0, animated: true)
            self.segmentedControl.insertSegment(withTitle: localizedString2, at: 1, animated: true)
            self.segmentedControl.selectedSegmentIndex = 0
        }
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(imageView)
        contentView.addSubview(topTextLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(semiDescriptionLabel)
        contentView.addSubview(backgroundView)
        contentView.addSubview(maskBackgroundView)
        maskBackgroundView.addSubview(circleView)
        contentView.addSubview(oneMonthButton)
        contentView.addSubview(descriptionOneMonthLabel)
        contentView.addSubview(oneYearButton)
        contentView.addSubview(descriptionOneYearLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(termsButton)
        contentView.addSubview(restoreButton)
        backgroundView.addSubview(monthsFreeLabel)
        backgroundView.addSubview(threeMonthsButton)
        backgroundView.addSubview(descriptionThreeMonthLabel)
        contentView.addSubview(extendedBackgroundView)
        contentView.addSubview(maskAnimatedBackgroundView)
        maskAnimatedBackgroundView.addSubview(cashFlowImage)
        maskAnimatedBackgroundView.addSubview(unknownImage)
        extendedBackgroundView.addSubview(extendedDescriptionTextLabel)
        extendedBackgroundView.addSubview(extendedTextLabel)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.top.left.right.width.equalToSuperview()
        }
        
        topTextLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topTextLabel.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp_bottom).offset(25)
            make.width.equalToSuperview()
            make.height.equalTo(80)
        }
        
        semiDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp_bottom).offset(25)
            make.left.equalToSuperview().offset(45)
            make.right.equalToSuperview().inset(45)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(semiDescriptionLabel.snp_bottom).offset(35)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        maskBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(31.5)
            make.height.equalTo(25)
            make.top.equalTo(backgroundView.snp_top).offset(-12)
        }
        
        circleView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(25)
        }
        
        monthsFreeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        threeMonthsButton.snp.makeConstraints { make in
            make.top.equalTo(monthsFreeLabel.snp_bottom).offset(10)
            make.left.equalToSuperview().offset(27.5)
            make.right.equalToSuperview().inset(27.5)
            make.height.equalTo(40)
        }
        
        descriptionThreeMonthLabel.snp.makeConstraints { make in
            make.top.equalTo(threeMonthsButton.snp_bottom).offset(7.5)
            make.left.equalToSuperview().offset(29)
            make.right.equalToSuperview().inset(29)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        oneMonthButton.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp_bottom).offset(30)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
            make.height.equalTo(40)
        }
        
        descriptionOneMonthLabel.snp.makeConstraints { make in
            make.top.equalTo(oneMonthButton.snp_bottom).offset(7.5)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        oneYearButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionOneMonthLabel.snp_bottom).offset(30)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
            make.height.equalTo(40)
        }
        
        descriptionOneYearLabel.snp.makeConstraints { make in
            make.top.equalTo(oneYearButton.snp_bottom).offset(7.5)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            constraintX = make.top.equalTo(descriptionOneYearLabel.snp_bottom).offset(25).constraint
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        termsButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp_bottom).offset(15)
            make.right.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp_bottom).offset(15)
            make.left.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        extendedTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
        
        extendedDescriptionTextLabel.snp.makeConstraints { make in
            make.top.equalTo(extendedTextLabel.snp_bottom).offset(12.5)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        unknownImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-1)
            make.right.equalTo(cashFlowImage.snp_left).offset(-7.5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.width.equalTo(25)
            make.top.equalToSuperview().offset(5)
        }
        
        cashFlowImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12.5)
            make.height.width.equalTo(25)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        maskAnimatedBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(97.5)
            make.height.equalTo(60)
            make.top.equalTo(extendedBackgroundView.snp_top).offset(-30)
        }
        
        extendedBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionOneYearLabel.snp_bottom).offset(45)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().inset(25)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var constraintX: Constraint? = nil

    func priceDisplasement(subscribeSet: [Price]) {
        DispatchQueue.main.async {
        guard subscribeSet.count > 2 else { return }
        let localizedString3Main = NSLocalizedString("payWall3MonthsButtonText", comment: "")
        let localizedString3Description = NSLocalizedString("payWall3MonthsDescription", comment: "")
        let localizedString1Main = NSLocalizedString("payWall1MonthsButtonText", comment: "")
        let localizedString1YearMain = NSLocalizedString("payWall1YearButtonText", comment: "")
        let localizedString1Description = NSLocalizedString("payWall1YearDescription", comment: "")
        let firstReplacementB = localizedString1Main.replacingOccurrences(of: "%PRICE%", with: subscribeSet[0].priceLocale)
        let secondReplacementB = localizedString3Main.replacingOccurrences(of: "%PRICE%", with: subscribeSet[1].introductoryPrice)
        let threeReplacementB = localizedString1YearMain.replacingOccurrences(of: "%PRICE%", with: subscribeSet[2].priceLocale)
        let replaceQuarterDescription = localizedString3Description.replacingOccurrences(of: "%PRICEF%", with: subscribeSet[1].introductoryPrice).replacingOccurrences(of: "%PRICES%", with: subscribeSet[1].priceLocale)
        self.descriptionThreeMonthLabel.text = "\(replaceQuarterDescription)"
        let discont = abs((subscribeSet[2].price as Decimal) - (subscribeSet[0].price as Decimal) * 12)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = .current
        guard let formattedPrice = numberFormatter.string(from: discont as NSNumber) else { return }
        let oneYearReplacement = localizedString1Description.replacingOccurrences(of: "%PRICE%",
                                                                                  with: "\(formattedPrice)")
        self.descriptionOneYearLabel.text = oneYearReplacement
        self.threeMonthsButton.setTitle(secondReplacementB, for: .normal)
        self.oneMonthButton.setTitle(firstReplacementB, for: .normal)
        self.oneYearButton.setTitle(threeReplacementB, for: .normal)
        }
    }
    
    @objc func plusManager() {
        DispatchQueue.main.async {
            
            switch self.state {
            case .show:
                self.state = .hide
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                    self.extendedBackgroundView.alpha = 0
                    self.extendedTextLabel.alpha = 0
                    self.extendedDescriptionTextLabel.alpha = 0
                    self.maskAnimatedBackgroundView.alpha = 0
                    self.constraintX?.update(offset: 25)
                    self.scrollView.layoutIfNeeded()
                }, completion: { _ in })
                
            case .hide:
                self.state = .show
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                    self.extendedBackgroundView.alpha = 1
                    self.extendedDescriptionTextLabel.alpha = 1
                    self.extendedTextLabel.alpha = 1
                    self.maskAnimatedBackgroundView.alpha = 1
                    self.constraintX?.update(offset: self.extendedBackgroundView.bounds.height + 60)
                    self.scrollView.layoutIfNeeded()
                }, completion: { _ in })
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        descriptionOneYearLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        descriptionOneMonthLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        descriptionThreeMonthLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        extendedDescriptionTextLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)
        extendedTextLabel.textColor = isDark ? .systemGray : .init(rgb: 0x1C1C1E)

    }
    
    
}

extension UIButton {
    func loadingIndicator(show: Bool, quarterly: Bool = false) {
        let tag = 808404
        if show {
            backgroundColor = backgroundColor?.withAlphaComponent(0.3)
            titleLabel?.layer.opacity = 0
            isEnabled = false
            let indicator = UIActivityIndicatorView()
            let buttonHeight = bounds.size.height
            let buttonWidth = bounds.size.width
            indicator.color = quarterly ? .systemPink : .systemBlue
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            addSubview(indicator)
            indicator.startAnimating()
        } else {
            backgroundColor = quarterly ? .systemPink : .systemBlue
            titleLabel?.layer.opacity = 1
            isEnabled = true
            alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}

