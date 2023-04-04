//
//  PinPointMenu.swift
//  LittleFoxEnglish
//
//  Created by LittleFox iOS Developer MacBook on 2018. 7. 18..
//  Copyright © 2018년 Tao. All rights reserved.
//

import UIKit


public protocol PinPointMenuBtnKindRequiresEnum: RawRepresentable where RawValue == Int{
    var imageName: String {get}
    var text: String {get}
}

public class PinPointMenu<T:PinPointMenuBtnKindRequiresEnum> : UIView{
    var pinPointMenuTapped: ((_ tag: T?)->())?

    private var statusBarHeight : CGFloat {
        if #available(iOS 11.0, *) {
            if let safeFrame = UIApplication.shared.windows.last?.safeAreaInsets{
                return Swift.max(safeFrame.top, safeFrame.left)
            }
        }
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
    private var bottomRoundedHeight_iphoneX: CGFloat{
        if #available(iOS 11.0, *) {
            if let safeFrame = UIApplication.shared.windows.first?.safeAreaInsets{
                return safeFrame.bottom
            }
        }
        
        return self.statusBarHeight
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

    let screenSize: CGSize
    
    public init(menuHeight: CGFloat, screenSize: CGSize, menuBtnKinds: [T], color: UIColor = UIColor(hexString: "#26d0df")) {
        
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
        let image = UIImage(named: "btn_plus", in: Bundle.module, compatibleWith: nil)
        self.startButton.setImage(image, for: .normal)
        self.startButton.addTarget(self, action: #selector(startCallback(sender:)), for: .touchUpInside)
        self.shapedBg.addSubview(self.startButton)

        self.menus = {
            var menus = [T.RawValue: PinPointMenuButton]()
            for i in 0..<menuBtnKinds.count{
                let data = menuBtnKinds[i]
                let btn = PinPointMenuButton(image: UIImage(named: data.imageName),//LFE_Images.center.loadImage(folder: .etc, imageName: data.imageName),
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

    @objc fileprivate func startCallback(sender: UIButton){
        self.spread()
    }

    @objc fileprivate func menuCallback(sender: UIButton){
        let tag = T(rawValue: sender.tag)
        self.pinPointMenuTapped?(tag)
    }
    
    public func showAndSpread(){
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.initPosition.y - 20
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.y = self.initPosition.y
            })
            self.spread()
        }
    }
    
    public func show(){
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.initPosition.y - 20
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.y = self.initPosition.y
            })
        }
    }
    
    public func hide(){
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
    
    private func prepareSpread(){
        let widthRate: CGFloat = 0.85
        self.startButton.alpha = 0
        self.center = CGPoint(x: screenSize.width * widthRate, y: screenSize.height - self.menuHeight/2 + self.menuHeight*0.1)
    }
    
    private func finishedSpread(duration: Double){
        let screenSize: CGSize = self.screenSize
        let widthRate: CGFloat = 0.85
        
        let extended_Height_IPhoeXAbove = self.menuHeight + self.bottomRoundedHeight_iphoneX*0.5
        self.frame = CGRect(origin: CGPoint(x: 0, y: screenSize.height - extended_Height_IPhoeXAbove),
                            size: CGSize(width: screenSize.width, height: extended_Height_IPhoeXAbove))

        let w = screenSize.width/self.maxBtnCount.toCGFloat
        let h = w * (200/225.0)
        let b = (screenSize.width - self.menuBtnKinds.count.toCGFloat*w)/(self.menuBtnKinds.count+1).toCGFloat

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
    
    public func spread(duration: Double = 0.4){
        
        if self.isAnimating {
            return
        }
        
        if isSpreaded {
            return
        }
        
        self.isAnimating = true
        
        
        UIView.animate(withDuration: 0.1, animations: {
            self.prepareSpread()
        }) { (_) in
            self.finishedSpread(duration: duration)
        }
    }
    
    public func recover(){
        
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
    
    
    public func setPinPointMenuTapped(closure: @escaping (_ tag: T?)->()){
        self.pinPointMenuTapped = closure
    }
    
    public func changeEnum(from: T, to: T) {
        guard let targetbtn = self.menus[from.rawValue] else {
            return
        }
        targetbtn.iconImage = UIImage(named: to.imageName)//LFE_Images.center.loadImage(folder: .etc, imageName: to.imageName)
        targetbtn.title = to.text
        targetbtn.tag = to.rawValue
        self.menus.removeValue(forKey: from.rawValue)
        self.menus[to.rawValue] = targetbtn
    }
    
    public func setButtonEnalbe(target: [T], isEnabled: Bool){
        for t in target{
            self.menus[t.rawValue]?.isEnabled = isEnabled
        }
    }
}
