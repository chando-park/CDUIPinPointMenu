//
//  PinPointMenu.swift
//  LittleFoxEnglish
//
//  Created by LittleFox iOS Developer MacBook on 2018. 7. 18..
//  Copyright © 2018년 Tao. All rights reserved.
//

import UIKit

protocol PinPointMenuProtocol: AnyObject{
    associatedtype T : PinPointMenuBtnKindRequiresEnum

    var menus: [T.RawValue : PinPointMenuButton]{get set}
    var menuBtnKinds: [T] {get set}
    var color: UIColor! {get set}
    
    var pinPointMenuTapped: ((_ tag: T?)->())? {get set}
}

extension PinPointMenuProtocol{
    func setPinPointMenuTapped(closure: @escaping (_ tag: T?)->()){
        self.pinPointMenuTapped = closure
    }
    
    func changeEnum(from: T, to: T) {
        guard let targetbtn = self.menus[from.rawValue] else {
            return
        }
        targetbtn.iconImage = LFE_Images.center.loadImage(folder: .etc, imageName: to.imageName)
        targetbtn.title = to.text
        targetbtn.tag = to.rawValue
        self.menus.removeValue(forKey: from.rawValue)
        self.menus[to.rawValue] = targetbtn
    }
    
    func setButtonEnalbe(target: [T], isEnabled: Bool){
        for t in target{
            self.menus[t.rawValue]?.isEnabled = isEnabled
        }
        
    }
    
    
}

protocol PinPointMenuBtnKindRequiresEnum: RawRepresentable where RawValue == Int{
    var imageName: String {get}
    var text: String {get}
}

class PinPointMenuButton: UIButton{

    override var isEnabled: Bool{
        didSet{
            super.isEnabled = self.isEnabled
            if self.isEnabled{
                //                self.backgroundColor = .clear
                UIView.animate(withDuration: 0.2) {
                    self.image?.alpha = 1
                    self.label?.alpha = 1
                }
                
            }else{
                UIView.animate(withDuration: 0.2) {
                    self.image?.alpha = 0.6
                    self.label?.alpha = 0.6
                }
            }
        }
    }
    
    var number: Int {
        set{
            if newValue == 0 {
                self.numberLabel?.isHidden = true
            }else{
                self.numberLabel?.isHidden = false
            }
            self.numberLabel?.text = "\(newValue)"
        }
        
        get{
            self.numberLabel?.text?.toInt ?? 0
        }
    }
    
    var iconImage: UIImage?{
        set{
            self.image.image = newValue
            self.imageResaurce = iconImage
        }
        get{
            self.imageResaurce
        }
    }
    
    var title: String?{
        set{
            self.label?.frame.size.width = self.frame.size.width
            self.label?.text = newValue
            self.label?.sizeToFit()
            self.label?.center.x = frame.size.width/2
            self.label?.frame.origin.y = self.image?.endPosY ?? 0
        }
        
        get{
            self.label.text
        }
    }
    
//    var isHideenNumer
    
    private var image: UIImageView!
    private var label: UILabel!
    
    private var imageResaurce: UIImage?
    private var fontSizeRate: CGFloat = 1
    
    var numberLabel: UILabel!
    
    
    init(image: UIImage?, text: String?, numberTextColor: UIColor = UIColor(hexString: "#26d0df"), initAlphaValue: CGFloat, fontSizeRate: CGFloat = 1){
        
        
        
        super.init(frame: .zero)

        self.fontSizeRate = fontSizeRate
        self.backgroundColor = .clear
        self.alpha = initAlphaValue
        
        self.image = UIImageView()
        self.image.contentMode = .scaleAspectFit
        self.addSubview(self.image)
        
        self.label = UILabel()
        self.label.textColor = UIColor.white
        self.label.numberOfLines = 2
        self.addSubview(self.label)
        
        self.imageResaurce = image
        self.label.text = text
        
        
        self.numberLabel = UILabel()
        self.numberLabel.textColor = numberTextColor
        self.numberLabel.textAlignment = .center
        self.numberLabel.backgroundColor = .white
        self.numberLabel.numberOfLines = 1
        
        self.number = 0

        self.addSubview(self.numberLabel)
    }
    
    override var frame: CGRect {
        didSet{
            super.frame = frame
            
            let rate: CGFloat = 0.66
            
            let deividedRate: CGFloat = (self.imageResaurce?.size.width ?? 110)/(self.imageResaurce?.size.height ?? 202)
//            let imageSizeWidth: CGFloat = frame.size.width
            let imageSizeHeight: CGFloat = self.frame.size.height*rate//imageSizeWidth*deividedRate
            let imageSizeWidth: CGFloat = imageSizeHeight*deividedRate
            
            self.image?.frame = CGRect(origin: CGPoint(x: self.frame.size.width/2-imageSizeWidth/2, y: 0), size: CGSize(width: imageSizeWidth, height: imageSizeHeight))
            self.image?.image = self.imageResaurce
            
            self.label?.font = UIFont.boldSystemFont(ofSize: (self.frame.size.height-imageSizeHeight)*self.getValueBy(ipad: 0.85, iphone: 0.6)*self.fontSizeRate)
            self.label?.frame.size.width = self.frame.size.width
            self.label?.sizeToFit()
            self.label?.center.x = frame.size.width/2
            self.label?.frame.origin.y = self.image?.endPosY ?? (frame.size.height-imageSizeHeight)
            
            let numberLabelH = imageSizeHeight*0.45*self.fontSizeRate
            self.numberLabel?.addRound(cornerRadius: numberLabelH/2, borderColor: .white)
            self.numberLabel?.frame = CGRect(origin: CGPoint(x: imageSizeWidth*self.getValueBy(ipad: 0.8, iphone: 0.6), y: imageSizeHeight*self.getValueBy(ipad: 0.1, iphone: 0.2)), size: CGSize(width: numberLabelH, height: numberLabelH))
            self.numberLabel?.font = UIFont.boldSystemFont(ofSize: numberLabelH*0.7*self.fontSizeRate)

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
class PinPointMenu<T:PinPointMenuBtnKindRequiresEnum> : UIView, PinPointMenuProtocol {
    var pinPointMenuTapped: ((_ tag: T?)->())?

    deinit {
        Log.p("PinPointMenu deinit")
    }
    

    lazy var scaleValue: CGFloat = {
        let maxLength = max(self.frame.size.width, self.frame.size.height)
        return (maxLength/self.circleSize.width) * 2
    }()
    
    private let maxBtnCount: Int = 5
    
    private var circleSize: CGSize!
    private var initPosition: CGPoint!
    
    private var shapedBg: UIView!
    private var startButton: UIButton!
    
    private var isAnimating: Bool = false
    
    var menuHeight: CGFloat!
    var menus: [T.RawValue : PinPointMenuButton] = [:]
    var menuBtnKinds: [T]
    var color: UIColor!
    var isSpreaded: Bool{
        get{
            return self.startButton.alpha == 0
        }
    }
    
//    var isHiddenNumber: Bool{
//        set{
//            self.num
//        }
//    }
    
    let screenSize: CGSize
    
    init(menuHeight: CGFloat, screenSize: CGSize, menuBtnKinds: [T], color: UIColor = UIColor(hexString: "#26d0df")) {
        
        self.screenSize = screenSize
        
        let rate: CGFloat = 0.7
        let circleSize = CGSize(width: menuHeight * rate, height: menuHeight * rate)
        let initMargen: CGPoint = CGPoint(x: circleSize.width*0.6, y: circleSize.width*0.5)
        let screenSize: CGSize = screenSize//UIScreen.main.bounds.size
        var initPosition = CGPoint(x: screenSize.width - initMargen.x - circleSize.width, y: screenSize.height - initMargen.y - circleSize.width)
        
        self.menuBtnKinds = menuBtnKinds
        
        super.init(frame: CGRect(origin: CGPoint(x: initPosition.x, y: initPosition.y + circleSize.height * 2), size: circleSize))
        initPosition.y -= (self.bottomRoundedHeight_iphoneX*0.5)
        
        self.backgroundColor = .clear
        self.clipsToBounds = true
        
        self.menuHeight = menuHeight// * Functions.work.getValueBy(ipad: 1, iphone: 1, iphoneX: 1.3)
        self.circleSize = circleSize
        self.initPosition = initPosition
        self.color = color
        
        self.shapedBg = UIView(frame: CGRect(origin: .zero, size: self.circleSize))
        self.shapedBg.backgroundColor = .clear
        self.addSubview(self.shapedBg)
        
        let shapedBgLayer = CAShapeLayer()
        shapedBgLayer.fillColor = color.cgColor
        shapedBgLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: self.circleSize)).cgPath
        shapedBg.layer.addSublayer(shapedBgLayer)
        
        self.startButton = UIButton(frame: self.shapedBg.bounds)
        self.startButton.setImage(LFE_Images.center.loadImage(folder: .etc, imageName: "btn_plus"), for: .normal)
        self.startButton.addTarget(self, action: #selector(startCallback(sender:)), for: .touchUpInside)
        self.shapedBg.addSubview(self.startButton)

        self.menus = {
            var menus = [T.RawValue: PinPointMenuButton]()
            for i in 0..<menuBtnKinds.count{
                let data = menuBtnKinds[i]
                let btn = PinPointMenuButton(image: LFE_Images.center.loadImage(folder: .etc, imageName: data.imageName),
                                             text: data.text,
                                             initAlphaValue: 0)
                btn.tag = data.rawValue
                btn.addTarget(self, action: #selector(menuCallback(sender:)), for: .touchUpInside)
                self.addSubview(btn)
                
                menus[data.rawValue] = btn
            }
            return menus
        }()
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    public func menuBtnEnable(tag: PinMenuEnum, isEnable: Bool){
//        self.menus[tag.rawValue]?.isEnabled = isEnable
//    }

    @objc fileprivate func startCallback(sender: UIButton){
        self.spread()
    }

    @objc fileprivate func menuCallback(sender: UIButton){
        let tag = T(rawValue: sender.tag)
        self.pinPointMenuTapped?(tag)
    }
    
    func showAndSpread(){
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.initPosition.y - 20
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.y = self.initPosition.y
            })
            self.spread()
        }
    }
    
    func show(){
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.initPosition.y - 20
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.y = self.initPosition.y
            })
        }
    }
    
    func hide(){
        func r_down() {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.y = self.initPosition.y + self.circleSize.height * 2
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
        func down(){
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.y = self.initPosition.y - self.circleSize.height/2
            }) { _ in
                r_down()
            }
        }
        if self.isSpreaded{
            r_down()
        }else{
            down()
        }
    }
    
    func spread(duration: Double = 0.4){
        
        if self.isAnimating {
            return
        }
        
        if isSpreaded {
            return
        }
        
        self.isAnimating = true
        
        let screenSize: CGSize = self.screenSize//UIScreen.main.bounds.size
        let widthRate: CGFloat = 0.85
        UIView.animate(withDuration: 0.1, animations: {
            self.startButton.alpha = 0
            self.center = CGPoint(x: screenSize.width * widthRate, y: screenSize.height - self.menuHeight/2 + self.menuHeight*0.1)
        }) { (_) in
            
            let extended_Height_IPhoeXAbove = self.menuHeight + self.bottomRoundedHeight_iphoneX*0.5
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenSize.height - extended_Height_IPhoeXAbove),
                                size: CGSize(width: screenSize.width, height: extended_Height_IPhoeXAbove))

            let w = screenSize.width/self.maxBtnCount.toCGFloat
            let h = w * (200/225.0)
            let b = (screenSize.width - self.menuBtnKinds.count.toCGFloat*w)/(self.menuBtnKinds.count+1).toCGFloat
            
//            for (index, value) in self.menus.sorted(by: {$0.key < $1.key}){
//                value.frame = CGRect(origin: CGPoint(x: b+(w+b)*index.toCGFloat, y: 0), size: CGSize(width: w, height: h))
//            }
            
            let sorted = self.menus.sorted(by: {$0.key < $1.key}).map({$1})
            for i in 0..<sorted.count{
                sorted[i].frame = CGRect(origin: CGPoint(x: b+(w+b)*i.toCGFloat, y: 0), size: CGSize(width: w, height: h))
            }

            self.shapedBg.center = CGPoint(x: screenSize.width * widthRate, y: self.menuHeight/2 + self.menuHeight*0.05)
            
            UIView.animate(withDuration: duration - 0.1, delay: 0, animations: {
                self.shapedBg.transform = CGAffineTransform(scaleX: self.scaleValue, y: self.scaleValue)
                for btn in self.menus.values{
                    btn.alpha = 1
                }
            }, completion: { _ in
                self.isAnimating = false
            })
        }
    }
    
    func recover(){
        
        if self.isAnimating {
            return
        }
        
        if !isSpreaded {
            return
        }
        
        self.isAnimating = true
        
        UIView.animate(withDuration: 0.3, animations: {
            for btn in self.menus.values{
                btn.alpha = 0
            }
            
            self.shapedBg.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (_) in
            for btn in self.menus.values{
                btn.frame = .zero
            }
            
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                self.startButton.alpha = 1
                self.shapedBg.frame.origin = .zero
                self.frame = CGRect(origin: self.initPosition, size: self.circleSize)
            }, completion: { _ in
                self.isAnimating = false
            })
        }
    }
    
    
}
