//
//  GLWalkThrough.swift
//  Protalk
//
//  Created by Gokul on 30/08/20.
//  Copyright © 2020 Possibilty. All rights reserved.
//

import UIKit

public protocol GLWalkThroughDataSource {
    func numberOfItems() -> Int
    func configForItemAtIndex(index:Int) -> GLWalkThroughConfig
}

public protocol GLWalkThroughDelegate {
    func didSelectNextAtIndex(index:Int)
    func didSelectSkip(index:Int)
}

open class GLWalkThrough: NSObject {
    private let window = UIApplication.shared.keyWindow
    private let windowFrame:CGRect = UIApplication.shared.keyWindow?.bounds ?? CGRect(x: 0, y: 0, width: 320, height: 568)
    
    private let deviceHeight = UIApplication.shared.keyWindow?.bounds.height
    
    // MARK: -- Var
    public var dataSource:GLWalkThroughDataSource!
    public var delegate:GLWalkThroughDelegate!
    public var isShowSkipButton:Bool = true
    public var skipButtonTitle = "Skip"
    fileprivate var currentConfig:GLWalkThroughConfig?
    fileprivate var fillLayer:CAShapeLayer?
    
    /// Parent view of GLWalkThrough
    fileprivate lazy var skipButton:UIButton = {
        let skip = UIButton()
        skip.addTarget(self, action: #selector(onTapSkip), for: .touchUpInside)
        skip.layer.cornerRadius = 8
        skip.layer.borderWidth  = 1
        skip.layer.borderColor = UIColor.white.cgColor
        skip.setTitle(skipButtonTitle, for: .normal)
        return skip
    }()
    
    fileprivate lazy var containerView:UIView = {
        let view = UIView(frame: windowFrame)
        view.backgroundColor = .clear
        if isShowSkipButton {
            view.addSubview(skipButton)
        }
        return view
    }()
    
    /// View which holds title subtitle and next button
    fileprivate lazy var contentView:GLWalkThroughContentView = {
        let view:GLWalkThroughContentView = .fromNib()
        guard let frame = currentConfig?.frameOverWindow else {return view}
        view.frame = CGRect(x: 0, y: frame.origin.y - 175, width: containerView.frame.size.width, height: 175)
        view.backgroundColor = .clear
        return view
    }()
    fileprivate var currentIndex = 0
    fileprivate var numberOfItems:Int = 0
    
    // MARK: - Init
    public func show() {
        guard let window = window else {return}
        window.addSubview(containerView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            window.bringSubview(toFront: self.containerView)
        }
        setupVFLForSkipButton()
        containerView.bringSubview(toFront: skipButton)
        getDataSource()
        contentView.onTapNext = {
            self.onTapNext()
        }
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapNext))
//        contentView.addGestureRecognizer(tap)
    }
    
    public func dismiss() {
        containerView.removeFromSuperview()
    }
   
    
    // MARK: - DataSource
    func getDataSource() {
        numberOfItems = dataSource?.numberOfItems() ?? 0
        getConfigForItemAt(index: 0)
    }
    
    func getConfigForItemAt(index:Int)  {
        guard let config =  dataSource?.configForItemAtIndex(index: index), let frame = config.frameOverWindow else {return}
        currentConfig = config
        currentIndex = index
        reloadUI()
        drawOverlay(myRect: frame)
    }
    
    // MARK: - Actions
    @objc func onTapNext() {
        let nextIndex = currentIndex + 1
        if nextIndex <= numberOfItems {
            delegate?.didSelectNextAtIndex(index: nextIndex)
            getConfigForItemAt(index: nextIndex)
        }
    }
    @objc func onTapSkip() {
        delegate?.didSelectSkip(index: currentIndex)
    }
    
    // MARK: - Draw Layer and UI
    private func reloadUI() {
        
        if currentIndex == 0 {
           containerView.addSubview(contentView)
        }
        
        contentView.titleLabel.text = currentConfig?.title
        contentView.subTitleLabel.text = currentConfig?.subtitle
        contentView.nextButton.setTitle("   \(currentConfig?.nextBtnTitle ?? "Next")   ", for: .normal)
        
        if let position = currentConfig?.position, let frame = currentConfig?.frameOverWindow {
            // Set y position depending on top or bottom
            if let frame = currentConfig?.frameOverWindow {
                if let isBottom = currentConfig?.isInBottom, isBottom {
                    contentView.frame.origin.y = frame.origin.y - contentView.frame.size.height
                }else{
                    contentView.frame.origin.y = frame.origin.y + frame.height + 10
                }
                
            }
            switch position {
                
            case .bottomLeft, .topLeft:
                let xAxis = frame.origin.x + (frame.size.width/2)
                contentView.leadingConstraint.constant = xAxis
                contentView.trailingConstraint.constant = 0
                
                contentView.leadingVerticleLine.isHidden = false
                contentView.trailingVerticleLine.isHidden = true
                
                contentView.titleLabel.textAlignment = .left
                contentView.subTitleLabel.textAlignment = .left
                
                contentView.nextButtonStack.alignment = .leading
            case .bottomRight, .topRight:
                let xAxis = (containerView.frame.size.width - frame.origin.x) - (frame.size.width/2)
                contentView.trailingConstraint.constant = xAxis
                contentView.leadingConstraint.constant = 0
                contentView.titleLabel.textAlignment = .right
                contentView.subTitleLabel.textAlignment = .right
                contentView.trailingVerticleLine.isHidden = false
                contentView.leadingVerticleLine.isHidden = true
                
                contentView.nextButtonStack.alignment = .trailing
            case .bottomCenter, .topCenter:
                contentView.trailingConstraint.constant = 0
                contentView.leadingConstraint.constant = 0
                
                contentView.trailingVerticleLine.isHidden = true
                contentView.leadingVerticleLine.isHidden = true
                
                contentView.titleLabel.textAlignment = .center
                contentView.subTitleLabel.textAlignment = .center
                
                contentView.nextButtonStack.alignment = .center
            }
        }
        setupVFLForSkipButton()
    }
    
    fileprivate func setupVFLForSkipButton() {
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        let  horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[skip(>=70)]-30-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["skip":skipButton])
        if let isBottom = currentConfig?.isInBottom, isBottom {
            let verticle  = NSLayoutConstraint.constraints(withVisualFormat: "V:|-55-[skip(35)]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["skip":skipButton])
           containerView.addConstraints(verticle)
        }else{
            let verticle  = NSLayoutConstraint.constraints(withVisualFormat: "V:[skip(35)]-55-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["skip":skipButton])
           containerView.addConstraints(verticle)
        }
         
        containerView.addConstraints(horizontal)
        
    }
    
    private func drawOverlay(myRect:CGRect) {
        if fillLayer != nil {
            fillLayer?.removeFromSuperlayer()
            fillLayer = nil
        }
        let radius: CGFloat = myRect.size.width
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height), cornerRadius: 0)
        let circlePath = UIBezierPath(roundedRect: myRect, cornerRadius: radius)
        path.append(circlePath)
        path.usesEvenOddFillRule = true

        fillLayer = CAShapeLayer()
        fillLayer?.path = path.cgPath
        fillLayer?.fillRule = kCAFillRuleEvenOdd
        fillLayer?.fillColor = UIColor.black.cgColor
        fillLayer?.opacity = 0.8
        containerView.layer.insertSublayer(fillLayer!, below: skipButton.layer)
    }
}

// MARK: -
public struct GLWalkThroughConfig {
    public init() {
        
    }
    public enum GLPosition {
        case bottomLeft
        case bottomRight
        case bottomCenter
        case topLeft
        case topRight
        case topCenter
    }
    public var frameOverWindow:CGRect!
    public var title:String?
    public var subtitle:String?
    public var nextBtnTitle:String = "Next"
    public var isSkipEnabled:Bool = true
    public var tapToNext:Bool = true
    public var position:GLPosition = .bottomLeft
    var isInBottom:Bool {
        return position == .bottomCenter || position == .bottomLeft || position == .bottomRight
    }
    
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: GLWalkThroughContentView.self)
            .loadNibNamed("GLWalkThroughContentView", owner:self, options:nil)![0] as! T
    }
}
