//
//  SYMineHeadView.swift
//  Nongjibang
//
//  Created by bsoshy on 2019/7/8.
//  Copyright © 2019 qiaoxy. All rights reserved.
//

import UIKit

typealias MineHeadConcernBlock = ()->()
class SYMineHeadView: UIView {

    var concernBlock : MineHeadConcernBlock!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        initSubview()
    }
    func initSubview() {
        self.addSubview(self.headImageView)
        self.headImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(-15)
            make.width.height.equalTo(60)
        }
        self.concernBtn.addTarget(self, action: #selector(concernBtnClick), for: .touchUpInside)
        self.addSubview(self.concernBtn)
        self.concernBtn.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.right.equalTo(-15)
            make.width.equalTo(70)
            make.height.equalTo(25)
        }
        self.addSubview(self.titleLab)
        titleLab.text = "张起灵"
        self.titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(headImageView.snp.right).offset(10)
            make.top.equalTo(8)
        }
        self.addSubview(self.levelLab)
        levelLab.text = "LV8"
        self.levelLab.snp.makeConstraints { (make) in
            make.left.equalTo(titleLab.snp.right).offset(6)
            make.height.equalTo(14)
            make.centerY.equalTo(titleLab.snp.centerY)
        }
        self.addSubview(self.stateImg)
        self.stateImg.snp.makeConstraints { (make) in
            make.left.equalTo(levelLab.snp.right).offset(6)
            make.centerY.equalTo(titleLab.snp.centerY)
            make.height.equalTo(14)
            make.width.equalTo(45)
            make.right.lessThanOrEqualTo(concernBtn.snp.left).offset(-8)
        }
        self.addSubview(self.addressLab)
        addressLab.text = "江苏省徐州市"
        self.addressLab.snp.makeConstraints { (make) in
            make.left.equalTo(headImageView.snp.right).offset(10)
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.right.equalTo(concernBtn.snp.left).offset(-8)
        }
      
        let ringSackView = UIStackView(arrangedSubviews: [self.ringNumLab,self.ringLab])
        ringSackView.axis = .vertical
        self.ringNumLab.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(ringSackView)
            make.height.equalTo(18)
        }
        self.ringLab.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(ringSackView)
            make.height.equalTo(18)
        }
        self.addSubview(ringSackView)
        ringSackView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(addressLab.snp.bottom).offset(20)
            make.width.equalTo(kScreenWidth/3-0.5)
            make.height.equalTo(36)
        }
        let fLine = UIView(frame: .zero)
        fLine.backgroundColor = UIColor(hexString: "#DDDDDD")
        self.addSubview(fLine)
        fLine.snp.makeConstraints { (make) in
            make.left.equalTo(ringSackView.snp.right)
            make.top.equalTo(addressLab.snp.bottom).offset(20)
            make.width.equalTo(1)
            make.height.equalTo(36)
        }
        
        let concernSackView = UIStackView(arrangedSubviews: [self.concernNumLab,self.concernLab])
        concernSackView.axis = .vertical
        self.concernNumLab.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(concernSackView)
            make.height.equalTo(18)
        }
        self.concernLab.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(concernSackView)
            make.height.equalTo(18)
        }
        self.addSubview(concernSackView)
        concernSackView.snp.makeConstraints { (make) in
            make.left.equalTo(fLine.snp.right)
            make.top.equalTo(addressLab.snp.bottom).offset(20)
            make.width.equalTo(kScreenWidth/3-0.5)
            make.height.equalTo(36)
        }
        let sLine = UIView(frame: .zero)
        sLine.backgroundColor = UIColor(hexString: "#DDDDDD")
        self.addSubview(sLine)
        sLine.snp.makeConstraints { (make) in
            make.left.equalTo(concernSackView.snp.right)
            make.top.equalTo(addressLab.snp.bottom).offset(20)
            make.width.equalTo(1)
            make.height.equalTo(36)
        }
        
        let fansSackView = UIStackView(arrangedSubviews: [self.fansNumLab,self.fansLab])
        fansSackView.axis = .vertical
        self.fansNumLab.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(fansSackView)
            make.height.equalTo(18)
        }
        self.fansLab.snp.makeConstraints { (make) in
            make.bottom.right.left.equalTo(fansSackView)
            make.height.equalTo(18)
        }
        self.addSubview(fansSackView)
        fansSackView.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.top.equalTo(addressLab.snp.bottom).offset(20)
            make.width.equalTo(kScreenWidth/3-0.5)
            make.height.equalTo(36)
        }
        
        let bottomView = UIView(frame: .zero)
        bottomView.backgroundColor = .backGray
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self)
            make.height.equalTo(9)
        }
        
    }
    
    @objc func concernBtnClick() {
        self.concernBlock?()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // get
    
    lazy var headImageView: UIImageView = {
        let topImg = UIImageView.init(frame:.zero)
        topImg.image = UIImage(named: "onepiece_kiudai")
        topImg.layer.cornerRadius = 30
        topImg.layer.borderColor = UIColor.white.cgColor
        topImg.layer.borderWidth = 2
        topImg.layer.masksToBounds = true
        return topImg
    }()
    lazy var titleLab: UILabel = {
        let title = UILabel(frame: .zero)
        title.font = .systemFont(ofSize: 15)
        title.textColor = .gray4Color
        return title
    }()
    lazy var concernBtn: UIButton = {
        let concern = UIButton(frame: .zero)
        concern.backgroundColor = .themeColor
        concern.setTitle("关注", for:.normal)
//        concern.setImage(UIImage(named: "icon_guanzhu0"), for: .normal)
        concern.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        concern.layer.cornerRadius = 25/2
        concern.titleLabel?.font = .systemFont(ofSize: 12)
        return concern
    }()
    lazy var levelLab: UILabel = {
        let level = UILabel(frame: .zero)
        level.backgroundColor = UIColor(hexString: "#FCC602")
        level.textColor = .white
        level.font = .systemFont(ofSize: 10)
        level.textAlignment = .center
        return level
    }()
    lazy var stateImg: UIImageView = {
        let state = UIImageView(frame: .zero)
//        state.image = UIImage(named: "yirenzheng_0")
        return state
    }()
    lazy var addressLab: UILabel = {
        let address = UILabel(frame: .zero)
        address.font = .systemFont(ofSize: 12)
        address.textColor = UIColor(hexString: "#888888")
        return address
    }()
    
    lazy var ringNumLab: UILabel = {
        let ring = UILabel(frame: .zero)
        ring.textAlignment = .center
        ring.text = "10"
        ring.textColor = .gray4Color
        ring.font = .systemFont(ofSize: 15)
        return ring
    }()
    lazy var ringLab: UILabel = {
        let ring = UILabel(frame: .zero)
        ring.textAlignment = .center
        ring.text = "圈子"
        ring.textColor = UIColor(hexString: "#888888")
        ring.font = .systemFont(ofSize: 12)
        return ring
    }()
    lazy var concernNumLab: UILabel = {
        let concern = UILabel(frame: .zero)
        concern.textAlignment = .center
        concern.text = "30"
        concern.textColor = .gray4Color
        concern.font = .systemFont(ofSize: 15)
        return concern
    }()
    lazy var concernLab: UILabel = {
        let concern = UILabel(frame: .zero)
        concern.textAlignment = .center
        concern.text = "关注"
        concern.textColor = UIColor(hexString: "#888888")
        concern.font = .systemFont(ofSize: 12)
        return concern
    }()
    
    lazy var fansNumLab: UILabel = {
        let fans = UILabel(frame: .zero)
        fans.textAlignment = .center
        fans.text = "20"
        fans.textColor = .gray4Color
        fans.font = .systemFont(ofSize: 15)
        return fans
    }()
    lazy var fansLab: UILabel = {
        let fans = UILabel(frame: .zero)
        fans.textAlignment = .center
        fans.text = "粉丝"
        fans.textColor = UIColor(hexString: "#888888")
        fans.font = .systemFont(ofSize: 12)
        return fans
    }()
}
