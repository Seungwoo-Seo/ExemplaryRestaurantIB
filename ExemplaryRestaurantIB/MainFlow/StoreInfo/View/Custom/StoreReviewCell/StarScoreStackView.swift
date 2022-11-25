//
//  StarScoreStackView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/13.
//

import UIKit
import SnapKit

class StarScoreStackView: UIStackView {
    
    // MARK: View
    private lazy var starImageView0: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var starImageView1: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var starImageView2: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var starImageView3: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var starImageView4: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Setup
extension StarScoreStackView: Setup {
    
    func setupUI() {
        setupUI_starImage0()
        setupUI_starImage1()
        setupUI_starImage2()
        setupUI_starImage3()
        setupUI_starImage4()
    }
    
}

// MARK: for setupUI
private extension StarScoreStackView {
    
    func setupUI_starImage0() {
        let imageView = self.starImageView0
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        self.addArrangedSubview(imageView)
    }
    
    func setupUI_starImage1() {
        let imageView = self.starImageView1
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        self.addArrangedSubview(imageView)
    }
    
    func setupUI_starImage2() {
        let imageView = self.starImageView2
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        self.addArrangedSubview(imageView)
    }
    
    func setupUI_starImage3() {
        let imageView = self.starImageView3
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        self.addArrangedSubview(imageView)
    }
    
    func setupUI_starImage4() {
        let imageView = self.starImageView4
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        self.addArrangedSubview(imageView)
    }

}
