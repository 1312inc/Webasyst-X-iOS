//
//  WelcomeViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    //MARK: Data variables
    var viewModel: WelcomeViewModelProtocol!
    
    //MARK: Interface elements variable
    private var logoImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "TextLogo"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var welcomeImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "BigLogo"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("appName", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionAppLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("appDescription", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var authButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("loginButtonTitle", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 5
        let origImage = UIImage(systemName: "lock.shield")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(tapLogin), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var githubButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("onGithub", comment: ""), for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(openGitHub), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var howAreWork: UILabel!
    
    var frame = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        pageControl.numberOfPages = self.viewModel.slides.count
        setupScreens()
        self.localized()
    }
    
    // Hide navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Show navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func localized() {
        howAreWork.text = NSLocalizedString("howItWorks", comment: "")
    }
    
    //MARK: Configuration of the carousel slides
    private func setupScreens() {
        for index in 0 ..< viewModel.slides.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            let slideView = UIView(frame: frame)
            switch viewModel.slides[index].type {
            case .slide(data: let slide):
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = UIImage(named: slide.image)
                imageView.contentMode = .scaleAspectFit
                slideView.addSubview(imageView)
                imageView.widthAnchor.constraint(equalToConstant: 86).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 86).isActive = true
                imageView.topAnchor.constraint(equalTo: slideView.topAnchor, constant: 170).isActive = true
                imageView.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
                let textLabel = UILabel()
                textLabel.translatesAutoresizingMaskIntoConstraints = false
                textLabel.text = self.viewModel.slides[index].title
                textLabel.font = UIFont.boldSystemFont(ofSize: 20)
                textLabel.textAlignment = .center
                textLabel.numberOfLines = 0
                slideView.addSubview(textLabel)
                textLabel.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20).isActive = true
                textLabel.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20).isActive = true
                textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
                let descriptionLabel = UILabel()
                descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
                descriptionLabel.text = slide.text
                descriptionLabel.font = UIFont.systemFont(ofSize: 15)
                descriptionLabel.textAlignment = .center
                descriptionLabel.numberOfLines = 0
                slideView.addSubview(descriptionLabel)
                descriptionLabel.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20).isActive = true
                descriptionLabel.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20).isActive = true
                descriptionLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20).isActive = true
                let nextButton: UIButton = UIButton()
                nextButton.backgroundColor = UIColor.systemBlue
                nextButton.setTitle(NSLocalizedString("nextButton", comment: ""), for: .normal)
                nextButton.layer.cornerRadius = 10
                nextButton.translatesAutoresizingMaskIntoConstraints = false
                nextButton.addTarget(self, action: #selector(nextSlide), for: .touchDown)
                slideView.addSubview(nextButton)
                nextButton.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20).isActive = true
                nextButton.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20).isActive = true
                nextButton.bottomAnchor.constraint(equalTo: slideView.bottomAnchor,constant: -20).isActive = true
                nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            case .auth:
                appNameLabel.text = viewModel.slides[index].title
                slideView.addSubview(self.appNameLabel)
                slideView.addSubview(self.descriptionAppLabel)
                slideView.addSubview(self.welcomeImage)
                slideView.addSubview(self.logoImage)
                slideView.addSubview(self.authButton)
                slideView.addSubview(self.githubButton)
                logoImage.topAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
                logoImage.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
                logoImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
                welcomeImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
                welcomeImage.centerYAnchor.constraint(equalTo: slideView.centerYAnchor, constant: -150).isActive = true
                welcomeImage.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
                welcomeImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
                appNameLabel.topAnchor.constraint(equalTo: welcomeImage.bottomAnchor, constant: 10).isActive = true
                appNameLabel.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
                descriptionAppLabel.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20).isActive = true
                descriptionAppLabel.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20).isActive = true
                descriptionAppLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 10).isActive = true
                githubButton.topAnchor.constraint(equalTo: descriptionAppLabel.bottomAnchor, constant: 10).isActive = true
                githubButton.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
                authButton.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20).isActive = true
                authButton.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20).isActive = true
                authButton.centerXAnchor.constraint(equalTo: slideView.centerXAnchor).isActive = true
                authButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
                authButton.bottomAnchor.constraint(equalTo: slideView.bottomAnchor, constant: -20).isActive = true
            }
            self.scrollView.addSubview(slideView)
            self.scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = false
        }
        scrollView.contentSize = CGSize(width: (scrollView.frame.size.width * CGFloat(viewModel.slides.count)), height: scrollView.frame.size.height - 50)
        scrollView.delegate = self
    }
    
    //MARK: User event
    @objc func tapLogin() {
        self.viewModel.tappedLoginButton()
    }
    
    @objc func nextSlide() {
        UIView.animate(withDuration: 0.5) {
            self.scrollView.contentOffset.x = self.scrollView.contentOffset.x + self.view.frame.width
        }
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        if pageControl.currentPage == viewModel.slides.count - 1 {
            UIView.animate(withDuration: 0.2) {
                self.howAreWork.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.howAreWork.alpha = 1
            }
        }
    }
    
    //MARK: Open GitHub
    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/1312inc/Webasyst-X-iOS") {
            UIApplication.shared.open(url)
        }
    }
    
}

extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        if pageControl.currentPage == viewModel.slides.count - 1 {
            UIView.animate(withDuration: 0.2) {
                self.howAreWork.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.howAreWork.alpha = 1
            }
        }
    }
}
