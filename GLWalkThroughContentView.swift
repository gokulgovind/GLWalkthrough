//
//  GLWalkThroughContentView.swift
//  Protalk
//
//  Created by Vijay on 08/12/20.
//  Copyright © 2020 Possibilty. All rights reserved.
//

import UIKit

class GLWalkThroughContentView: UIView {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subTitleLabel:UILabel!
    @IBOutlet weak var leadingVerticleLine:UIView!
    @IBOutlet weak var trailingVerticleLine:UIView!
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var nextButtonStack:UIStackView!
    
    
    @IBOutlet weak var leadingConstraint:NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint:NSLayoutConstraint!
    
    var onTapNext:(()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        nextButton.layer.cornerRadius = 5
        nextButton.layer.borderColor  = UIColor.white.cgColor
        nextButton.layer.borderWidth = 1.0
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        onTapNext?()
    }
}
