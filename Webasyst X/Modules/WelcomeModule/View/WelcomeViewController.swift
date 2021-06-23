//
//  WelcomeViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

enum SlideViewType {
    case slideView(view: SlideView)
    case authView(view: AuthSlide)
}

struct SliderViews {
    var views: SlideViewType
}

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    //MARK: Data variables
    var viewModel: WelcomeViewModelProtocol!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var frame = CGRect.zero
    var slides: [SliderViews] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        setupLayoutAndLocalized()
    }
    
    private func setupLayoutAndLocalized() {
        self.view.backgroundColor = .systemBackground
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [SliderViews] {
        var slideViews: [SliderViews] = []
        for slides in self.viewModel.slides {
            switch slides.type {
            case .slide(data: let data):
                let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
                slide.imageSlide.image = UIImage(named: data.image)
                slide.titleLabel.text = slides.title
                slide.descriptionLabel.text = data.text
                slideViews.append(SliderViews(views: .slideView(view: slide)))
            case .auth:
                let slide: AuthSlide = AuthSlide()
                slide.delegate = self
                slideViews.append(SliderViews(views: .authView(view: slide)))
            }
        }
        return slideViews
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    func setupSlideScrollView(slides : [SliderViews]) {
        self.scrollView.contentSize.height = 1.0
        if let window = UIApplication.shared.windows.last {
            self.scrollView.contentSize.width = window.safeAreaLayoutGuide.layoutFrame.width * CGFloat(slides.count)
        }
        for i in 0 ..< slides.count {
            switch slides[i].views {
            case .slideView(view: let view):
                scrollView.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalTo: self.scrollView.safeAreaLayoutGuide.heightAnchor).isActive = true
                view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
                view.delegate = self
                if i != 0 {
                    let lastView = scrollView.subviews[scrollView.subviews.count - 2]
                    view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                } else {
                    view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
                }
            case .authView(view: let view):
                scrollView.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
                view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
                view.delegate = self
                let lastView = scrollView.subviews[scrollView.subviews.count - 2]
                print(type(of: lastView))
                view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
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

extension WelcomeViewController: SlideViewDelegate {
    
    //MARK: Next button tap
    func nextButtonTap() {
        UIView.animate(withDuration: 0.5) {
            self.scrollView.contentOffset.x += self.view.frame.width
        }
    }
    
}

extension WelcomeViewController: AuthViewDelegate {
    
    //MARK: Open GitHub
    func openGithub() {
        if let url = URL(string: "https://github.com/1312inc/Webasyst-X-iOS") {
            UIApplication.shared.open(url)
        }
    }
    
    //MARK: Open phone authorization
    func phoneLogin() {
        self.viewModel.openPhoneAuth()
    }
    
    //MARK: Webasyst ID authorization
    func webasystIDLogin() {
        self.viewModel.tappedLoginButton()
    }
    
    
}
