//
//  File.swift
//  
//
//  Created by Littlefox iOS Developer on 2023/03/30.
//

import UIKit

public class PinPointMenuButton: UIButton{

    public override var isEnabled: Bool{
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
            Int(self.numberLabel?.text ?? "0") ?? 0
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
    
    
    public init(image: UIImage?, text: String?, numberTextColor: UIColor = UIColor(hexString: "#26d0df"), initAlphaValue: CGFloat, fontSizeRate: CGFloat = 1){
        
        
        
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
    
    public override var frame: CGRect {
        didSet{
            super.frame = frame
            
            let rate: CGFloat = 0.66
            
            let deividedRate: CGFloat = (self.imageResaurce?.size.width ?? 110)/(self.imageResaurce?.size.height ?? 202)
//            let imageSizeWidth: CGFloat = frame.size.width
            let imageSizeHeight: CGFloat = self.frame.size.height*rate//imageSizeWidth*deividedRate
            let imageSizeWidth: CGFloat = imageSizeHeight*deividedRate
            
            self.image?.frame = CGRect(origin: CGPoint(x: self.frame.size.width/2-imageSizeWidth/2, y: 0), size: CGSize(width: imageSizeWidth, height: imageSizeHeight))
            self.image?.image = self.imageResaurce
            
            self.label?.font = UIFont.boldSystemFont(ofSize: (self.frame.size.height-imageSizeHeight)*getValueBy(ipad: 0.85, iphone: 0.6)*self.fontSizeRate)
            self.label?.frame.size.width = self.frame.size.width
            self.label?.sizeToFit()
            self.label?.center.x = frame.size.width/2
            self.label?.frame.origin.y = self.image?.endPosY ?? (frame.size.height-imageSizeHeight)
            
            let numberLabelH = imageSizeHeight*0.45*self.fontSizeRate
            self.numberLabel?.addRound(cornerRadius: numberLabelH/2, borderColor: .white)
            self.numberLabel?.frame = CGRect(origin: CGPoint(x: imageSizeWidth*getValueBy(ipad: 0.8, iphone: 0.6), y: imageSizeHeight*getValueBy(ipad: 0.1, iphone: 0.2)),
                                             size: CGSize(width: numberLabelH, height: numberLabelH))
            self.numberLabel?.font = UIFont.boldSystemFont(ofSize: numberLabelH*0.7*self.fontSizeRate)

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
