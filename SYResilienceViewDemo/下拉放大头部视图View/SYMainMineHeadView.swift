//
//  SYMainMineHeadView.swift
//  Nongjibang
//
//  Created by bsoshy on 2019/7/10.
//  Copyright © 2019 qiaoxy. All rights reserved.
//

import UIKit

typealias MainMineHeadClickBlock = ()->()
class SYMainMineHeadView: UIView {
    
    let titles = ["我的圈子","我的关注","我的粉丝","我的收藏"]
    var clickBlock : MainMineHeadClickBlock!
    private let avatarImageH: CGFloat = 55
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizesSubviews = true
        initSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initSubview() {
        
        self.backgroundColor = .backGray
        self.addSubview(self.backView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(backViewClick))
        self.backView.addGestureRecognizer(tap)
        self.addSubview(self.msgView)
        backView.addSubview(self.headImg)
        updateLoginUI()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        msgView.addSubview(self.collectionView)
        backView.autoresizingMask = [.flexibleHeight]
        msgView.autoresizingMask = [.flexibleTopMargin]
        
        msgView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-10)
            make.height.equalTo(71)
        }
        headImg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalTo(msgView.snp.top).offset(-18)
            make.width.height.equalTo(avatarImageH)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.left.equalTo(8)
            make.right.bottom.equalTo(-8)
        }
    }
    
    //更新头部登录与否信息
    func updateLoginUI() {
        
    }
    
    //登录成功之后UI
    func configureLoginSuccessUI() {
        backView.addSubview(self.arrowBtn)
        backView.addSubview(self.nameLab)
        backView.addSubview(self.stateLab)
        backView.addSubview(self.progressView)
        backView.addSubview(self.gradeBtn)
        backView.addSubview(self.sufferImg)
        backView.addSubview(self.sufferLab)
        
        arrowBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.height.equalTo(60)
            make.width.equalTo(8)
            make.centerY.equalTo(headImg.snp.centerY)
        }
        nameLab.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(13)
            make.top.equalTo(headImg.snp.top).offset(2)
        }
        stateLab.snp.makeConstraints { (make) in
            make.left.equalTo(nameLab.snp.right).offset(8)
            make.width.equalTo(38)
            make.height.equalTo(15)
            make.centerY.equalTo(nameLab.snp.centerY)
            make.right.lessThanOrEqualTo(arrowBtn.snp.left)
        }
        progressView.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(13)
            make.width.equalTo(kScreenWidth/2-50)
            make.top.equalTo(nameLab.snp.bottom).offset(8)
            make.height.equalTo(5)
        }
        gradeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(headImg.snp.right).offset(13)
            make.top.equalTo(progressView.snp.bottom).offset(8)
            //            make.right.equalTo(arrowBtn.snp.left).offset(-8)
            make.height.equalTo(12)
        }
        sufferImg.snp.makeConstraints { (make) in
            make.left.equalTo(gradeBtn.snp.right).offset(10)
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.width.equalTo(12)
            make.height.equalTo(9)
        }
        sufferLab.snp.makeConstraints { (make) in
            make.left.equalTo(sufferImg.snp.right).offset(3)
            make.top.equalTo(progressView.snp.bottom).offset(8)
            make.right.equalTo(arrowBtn.snp.left).offset(-8)
            make.height.equalTo(12)
        }
        
    }
    
    @objc func backViewClick() {
        self.clickBlock?()
    }
  
    
    // get
    lazy var backView: UIImageView = {
        let back = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 144))
        let image = back.backImageFromColors(colors: [UIColor(hexString: "#F97015"),UIColor(hexString: "#EE500A")], gradientType: .topToBottom)
        back.isUserInteractionEnabled = true
        back.image = image
        return back
    }()
    lazy var msgView: UIView = {
        let msg = UIView(frame: CGRect(x: 15, y: 120, width: kScreenWidth-30, height: 71))
        msg.layer.cornerRadius = 9
        msg.backgroundColor = .white
        return msg
    }()
    lazy var headImg: UIImageView = {
        let head = UIImageView(frame: .zero)
        head.image = UIImage(named: "touxiang_moren")
        head.layer.cornerRadius = avatarImageH / 2
        head.layer.masksToBounds = true
        return head
    }()
    lazy var arrowBtn: UIButton = {
        let arrow = UIButton(type: .custom)
        arrow.setImage(UIImage(named: "icon_left_1"), for: .normal)
        return arrow
    }()
    lazy var nameLab: UILabel = {
        let name = UILabel(frame: .zero)
        name.font = UIFont.systemFont(ofSize: 15)
        name.textColor = .white
        return name
    }()
    lazy var stateLab: UILabel = {
        let state = UILabel(frame: .zero)
        state.backgroundColor = UIColor(hexString: "#00B22A")
        state.font = UIFont.systemFont(ofSize: 10)
        state.textAlignment = .center
        state.text = "已认证"
        state.textColor = .white
        state.layer.cornerRadius = 15/2
        state.layer.masksToBounds = true
        return state
    }()
    lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor(white: 1, alpha: 0.3)
        for imageview in progress.subviews {
            imageview.layer.cornerRadius = 2.5
            imageview.clipsToBounds = true
        }
        progress.progressTintColor = UIColor(hexString: "#F8F18C")
        return progress
    }()
    lazy var gradeBtn: UIButton = {
        let grade = UIButton(type: .custom)
        grade.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return grade
    }()
    lazy var sufferImg: UIImageView = {
        let suffer = UIImageView(frame: .zero)
        suffer.image = UIImage(named: "icon_jingyan")
        return suffer
    }()
    
    lazy var sufferLab: UILabel = {
        let suffer = UILabel(frame: .zero)
        suffer.font = UIFont.systemFont(ofSize: 12)
        suffer.textColor = UIColor(hexString: "#FCE5CA")
        return suffer
    }()
    lazy var loginLabel: UILabel = {
        let loginLab = UILabel()
        loginLab.text = "登录"
        loginLab.font = UIFont.systemFont(ofSize: 15)
        loginLab.textColor = UIColor.white
        return loginLab
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (kScreenWidth-50)/4, height: 50)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(UINib(nibName: "SYMainMineHeadCell", bundle: nil), forCellWithReuseIdentifier: "SYMainMineHeadCell")
        collection.backgroundColor = .white
        return collection
    }()
    
}
extension SYMainMineHeadView : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SYMainMineHeadCell", for: indexPath) as! SYMainMineHeadCell
        let titleStr = titles[indexPath.row]
        cell.titleLab.text = titleStr
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(1)
    }
    
}
