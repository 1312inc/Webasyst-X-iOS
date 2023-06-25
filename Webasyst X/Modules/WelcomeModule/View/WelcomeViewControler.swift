//
//  Welcome module - WelcomeViewController.swift
//  Teamwork
//
//  Created by viktkobst on 19/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class WelcomeViewController: UIViewController {
    
    //MARK: ViewModel property
    var viewModel: WelcomeViewModel?
    var coordinator: WelcomeCoordinator?
    
    private var disposeBag = DisposeBag()
    
    lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.systemGray2
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    var frame = CGRect.zero
    var slides: [SliderViews] = []
    
    //MARK: Interface elements propertys
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindableViewModel()
    }
    
    //MARK: Bindable ViewModel
    private func bindableViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.slides
            .subscribe(onNext: { [weak self] slides in
                guard let self = self else { return }
                var slideViews: [SliderViews] = []
                for slides in slides {
                    switch slides.type {
                    case .slide(data: let data):
                        let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
                        slide.imageSlide.image = UIImage(named: data.image)
                        slide.titleLabel.text = slides.title
                        slide.descriptionLabel.text = data.text
                        slideViews.append(SliderViews(views: .slideView(view: slide)))
                    }
                }
                self.slides = slideViews
                self.setupLayout()
            }).disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .systemBackground
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        self.view.addSubview(scrollView)
        self.view.addSubview(pageControl)
        
        scrollView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.pageControl.snp.top).offset(-20)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(self.scrollView.snp.bottom).offset(20)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-20)
        }
        
        setupSlideScrollView(slides: slides)
    }
    
    func setupSlideScrollView(slides : [SliderViews]) {
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        self.scrollView.contentSize.height = 1.0
        if let window = UIApplication.shared.windows.last {
            self.scrollView.contentSize.width = window.safeAreaLayoutGuide.layoutFrame.width * CGFloat(slides.count)
        }
        for i in 0 ..< slides.count {
            switch slides[i].views {
            case .slideView(view: let view):
                scrollView.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.snp.makeConstraints { [weak self] make in
                    guard let self = self else { return }
                    make.height.equalTo(self.scrollView.snp.height)
                    make.width.equalTo(self.view)
                }
                view.nextButton.tag = i
                view.delegate = self
                if i != 0 {
                    let lastView = scrollView.subviews[scrollView.subviews.count - 2]
                    view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                } else {
                    view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
                }
            }
        }
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Show navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

//MARK: SlideViewDelegate
extension WelcomeViewController: SlideViewDelegate {
    
    //MARK: Next button tap
    func nextButtonTap() {
        if sender.tag != 2 {
            UIView.animate(withDuration: 0.2) {
                self.scrollView.contentOffset.x += self.view.frame.width
            }
        } else {
            coordinator?.openAuthController()
        }
    }
    
}

//MARK: UIScrollViewDelegate
extension WelcomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
}
