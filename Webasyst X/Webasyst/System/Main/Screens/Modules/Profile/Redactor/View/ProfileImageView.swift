//
//  ProfileImageView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 25.03.2023.
//

import UIKit

protocol ProfileImageViewDelegate: AnyObject {
    func hideImage(_ completion: @escaping () -> ())
}

class ProfileImageView: UIView {
    
    var isHidding = false
    override var isHidden: Bool {
        didSet {
            isHidding = false
            setupFrames()
        }
    }
    
    public var profileImage: UIImage? {
        didSet {
            self.profileImageView.image = profileImage
        }
    }
    
    private weak var delegate: ProfileImageViewDelegate?
    private var defaultFrame: CGRect?

    init(delegate: ProfileImageViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        configure()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let blurryView: BlurryView = {
        let blurryView = BlurryView()
        blurryView.alpha = 0.9
        blurryView.setup()
        return blurryView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.minimumZoomScale = 1.0
        scrollV.maximumZoomScale = 3.0
        scrollV.translatesAutoresizingMaskIntoConstraints = false
        scrollV.alwaysBounceVertical = false
        scrollV.alwaysBounceHorizontal = false
        scrollV.showsVerticalScrollIndicator = false
        scrollV.showsHorizontalScrollIndicator = false
        return scrollV
    }()
}

private
extension ProfileImageView {
    
    func setupFrames() {
        if let image = self.profileImageView.image {
            let imgViewSize = self.profileImageView.frame.size
            let imageSize = image.size
            
            let realImgSize: CGSize
            if imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height {
                realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height)
            } else {
                realImgSize = CGSizeMake(imgViewSize.height, imgViewSize.height / imageSize.width * imageSize.height)
            }
            
            var fr = CGRectMake(0, 0, 0, 0)
            fr.size = realImgSize
            self.profileImageView.frame = fr
            
            let scrSize = self.scrollView.frame.size
            let offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0)
            let offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 : 0)
            self.scrollView.contentInset = UIEdgeInsets(top: offy, left: offx, bottom: offy, right: offx);
        }
    }
    
    func configure() {
        
        scrollView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide(_:)))
        scrollView.addGestureRecognizer(tap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoom(_:)))
        doubleTap.numberOfTapsRequired = 2
        profileImageView.addGestureRecognizer(doubleTap)
    }
    
    func setupLayouts() {
        
        addSubview(blurryView)
        addSubview(scrollView)
        scrollView.addSubview(profileImageView)

        blurryView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(profileImageView.snp.width)
        }
    }
    
    func hide(with completion: @escaping () -> () = {}) {
        isHidding = true
        delegate?.hideImage(completion)
    }
}

@objc
extension ProfileImageView {
    
    private func panDetected(_ sender: UIPanGestureRecognizer) {
        if isHidden || scrollView.zoomScale > scrollView.minimumZoomScale || !profileImageView.isUserInteractionEnabled { return }
        switch sender.state {
        case .began:
            defaultFrame = profileImageView.frame
        case .changed:
            guard let defaultFrame = defaultFrame else { return }
            let translation = sender.translation(in: self)
            let point = CGPoint(x: profileImageView.center.x, y: profileImageView.center.y + translation.y)
            profileImageView.center = point
            sender.setTranslation(CGPoint.zero, in: self)
            let step = (defaultFrame.height / 4) / 100
            if profileImageView.frame.midY <= defaultFrame.midY {
                let currentPosition = ((profileImageView.frame.maxY - defaultFrame.height / 4) - defaultFrame.midY)
                profileImageView.alpha = currentPosition / step / 100
                if currentPosition < 0 {
                    profileImageView.isUserInteractionEnabled = false
                    hide() { [weak self] in
                        guard let self = self else { return }
                        self.profileImageView.frame = defaultFrame
                        self.profileImageView.alpha = 1
                        self.defaultFrame = nil
                        self.profileImageView.isUserInteractionEnabled = true
                    }
                }
            } else {
                let currentPosition = (defaultFrame.midY - (profileImageView.frame.minY + defaultFrame.height / 4))
                profileImageView.alpha = currentPosition / step / 100
                if currentPosition < 0 {
                    profileImageView.isUserInteractionEnabled = false
                    hide() { [weak self] in
                        guard let self = self else { return }
                        self.profileImageView.frame = defaultFrame
                        self.profileImageView.alpha = 1
                        self.defaultFrame = nil
                        self.profileImageView.isUserInteractionEnabled = true
                    }
                }
            }
        case .ended:
            guard let defaultFrame = defaultFrame else { return }
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction]) {
                self.profileImageView.frame = defaultFrame
                self.profileImageView.alpha = 1
            } completion: { successed in
                if !successed {
                    self.profileImageView.frame = defaultFrame
                    self.profileImageView.alpha = 1
                }
                self.defaultFrame = nil
            }
        default:
            break
        }
    }
    
    private func hide(_ sender: UITapGestureRecognizer) {
        if isHidding { return }
        if !profileImageView.frame.contains(sender.location(in: scrollView)) {
            hide()
        }
    }
    
    private func zoom(_ sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: profileImageView)
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(1, animated: true)
            if let image = profileImageView.image {
                let imgViewSize = profileImageView.frame.size
                let imageSize = image.size
                
                let realImgSize: CGSize
                if imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height {
                    realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height)
                } else {
                    realImgSize = CGSizeMake(imgViewSize.height, imgViewSize.height / imageSize.width * imageSize.height)
                }
                
                var fr = CGRectMake(0, 0, 0, 0)
                fr.size = realImgSize
                profileImageView.frame = fr
                
                let scrSize = scrollView.frame.size
                let offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0)
                let offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 : 0)
                self.scrollView.contentInset = UIEdgeInsets(top: offy, left: offx, bottom: offy, right: offx);
            }
        } else {
            let zoomRect = zoomrectForScale(scale: scrollView.maximumZoomScale * 0.75, with: point)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomrectForScale(scale: CGFloat, with center: CGPoint) -> CGRect {
        
        var zoomRect = CGRect()
        
        zoomRect.size.height = profileImageView.frame.size.height / scale
        zoomRect.size.width = profileImageView.frame.size.width / scale
        
        zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0))
        zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0))
        
        return zoomRect
    }
}

extension ProfileImageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isHidding { return }
        
        if scrollView.zoomScale < 0.8 {
            hide()
        } else {
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(panDetected(_:)))
                profileImageView.addGestureRecognizer(pan)
            } else {
                profileImageView.gestureRecognizers?.forEach({ profileImageView.removeGestureRecognizer($0) })
            }
            if let image = profileImageView.image {
                let imgViewSize = profileImageView.frame.size
                let imageSize = image.size
                
                let realImgSize: CGSize
                if imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height {
                    realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height)
                } else {
                    realImgSize = CGSizeMake(imgViewSize.height, imgViewSize.height / imageSize.width * imageSize.height)
                }
                
                var fr = CGRectMake(0, 0, 0, 0)
                fr.size = realImgSize
                profileImageView.frame = fr
                
                let scrSize = scrollView.frame.size
                let offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0)
                let offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 : 0)
                self.scrollView.contentInset = UIEdgeInsets(top: offy, left: offx, bottom: offy, right: offx);
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return profileImageView
    }
}
