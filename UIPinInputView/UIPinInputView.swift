//
//  UIPinView.swift
//  ICBC
//
//  Created by apple-sysadmin on 5.02.2018.
//  Copyright © 2018 Magis Technology. All rights reserved.
//

import UIKit

class UIPinInputView: UIView {
    
    @IBInspectable var itemCount: Int = 1
    @IBInspectable var itemWidth: CGFloat = 20
    @IBInspectable var fontFamily: String = "OpenSans-Regular"
    @IBInspectable var fontSize: CGFloat = 10
    
    @IBInspectable var clearColor: UIColor = UIColor.red
    @IBInspectable var maskColor: UIColor = UIColor.blue
    @IBInspectable var fillColor: UIColor = UIColor.yellow
    
    @IBOutlet @objc public var delegate: PinViewDelegate?
    
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet
    public var ibDelegate: Any? {
        get { return delegate }
        set { delegate = newValue as? PinViewDelegate }
    }
    
    private var collectionView: UICollectionView!
    private var pinTextField: UITextField!
    private var pinItems = [String]()
    private var pinCursor: Int = 0
    
    private var maskFont: UIFont {
        return UIFont(name: fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: 19)
    }
    
    func initalize() {
        for _ in 0...itemCount-1 {
            pinItems.append("")
        }
        
        pinTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        pinTextField.backgroundColor = UIColor.blue
        pinTextField.becomeFirstResponder()
        pinTextField.isHidden = true
        pinTextField.text = "__________"
        pinTextField.delegate = self
        pinTextField.keyboardType = .numberPad
        self.addSubview(pinTextField)
        
        let width = CGFloat(pinItems.count) * itemWidth
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: itemWidth), collectionViewLayout: layout)
        
        collectionView.register(PinCollectionCell.self, forCellWithReuseIdentifier: "PinCollectionCell")
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsSelection = false
        collectionView.scrollsToTop = false
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        let heightConstraint = NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: itemWidth)
        
        let xConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.collectionView.addConstraint(widthConstraint)
        self.collectionView.addConstraint(heightConstraint)
        self.collectionView.updateConstraintsIfNeeded()
        
        self.addConstraint(xConstraint)
        self.addConstraint(yConstraint)
        self.updateConstraintsIfNeeded()
        
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func clearPin() {
        pinItems = []
        pinCursor = 0
        for _ in 0...itemCount-1 {
            pinItems.append("")
        }
        pinTextField.text = "__________"
        self.reloadData()
    }
    
    func reloadData() {
        self.pinTextField.becomeFirstResponder()
        self.collectionView.reloadData()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return self.pinTextField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return self.pinTextField.resignFirstResponder()
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        return self.pinTextField.endEditing(force)
    }
    
}


extension UIPinInputView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let pin = Int(string), pin <= 9, pin >= 0 {
            if let cell = collectionView.cellForItem(at: IndexPath(item: pinCursor, section: 0)) as? PinCollectionCell {
                if pinCursor == pinItems.count - 1, pinItems[pinCursor].isEmpty == false {
                    return false
                }
                
                cell.set(pin: String(pin), newInput: true)
                pinItems[pinCursor] = String(pin)
                
                if pinCursor > 0, pinItems[pinCursor-1].isEmpty == false,
                    let previousCell = collectionView.cellForItem(at: IndexPath(item: pinCursor-1, section: 0)) as? PinCollectionCell {
                    previousCell.blackPin()
                }
                
                if pinCursor <= pinItems.count - 1 {
                    pinCursor = pinCursor + 1
                }
                let finalPin = pinItems.joined()
                if finalPin.count == pinItems.count {
                    delegate?.pinView(self, pinFinished: finalPin)
                }
                return true
            }
        } else {
            let char = string.cString(using: .utf8)
            if strcmp(char, "\\b") == -92 {
                if pinCursor > 0 {
                    pinCursor = pinCursor - 1
                }
                if let cell = collectionView.cellForItem(at: IndexPath(item: pinCursor, section: 0)) as? PinCollectionCell {
                    cell.clearPin()
                    if pinItems[pinCursor] == "" {
                        return false
                    }
                    pinItems[pinCursor] = ""
                    return pinCursor >= 0
                }
                return false
            }
        }
        return false
    }
    
}

extension UIPinInputView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinCollectionCell", for: indexPath) as! PinCollectionCell
        cell.initViews(itemWidth: itemWidth, font: maskFont, clearColor: clearColor, maskColor: maskColor, fillColor: fillColor)
        cell.set(pin: pinItems[indexPath.row], newInput: false)
        return cell
    }
    
}

@objc protocol PinViewDelegate {
    
    func pinView(_ pinView: UIPinInputView, pinFinished: String)
    
}

fileprivate class PinCollectionCell: UICollectionViewCell {
    
    private var pinView: UIView!
    private var pinLabel: UILabel!
    
    private var clearColor: UIColor!
    private var maskColor: UIColor!
    private var fillColor: UIColor!
    
    func initViews(itemWidth: CGFloat, font: UIFont, clearColor: UIColor, maskColor: UIColor, fillColor: UIColor) {
        self.clearColor = clearColor
        self.maskColor = maskColor
        self.fillColor = fillColor
        if pinView == nil {
            pinView = UIView(frame: CGRect(x: 2, y: 2, width: itemWidth - 4, height: itemWidth - 4))
            
            pinLabel = UILabel(frame: pinView.bounds)
            pinLabel.textAlignment = .center
            pinLabel.font = font
            pinView.addSubview(pinLabel)
            
            self.addSubview(pinView)
        }
    }
    
    func set(pin: String, newInput: Bool) {
        self.pinView.layer.cornerRadius = self.pinView.bounds.width / 2
        self.pinView.layer.borderWidth = 1
        if newInput {
            whitePin()
            self.pinLabel.text = pin
            Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(blackPin), userInfo: nil, repeats: false)
        } else {
            if pin.isEmpty {
                clearPin()
            } else {
                blackPin()
            }
        }
    }
    
    func clearPin() {
        self.pinLabel.text = ""
        self.pinView.layer.backgroundColor = clearColor.cgColor
        self.pinView.layer.borderColor = fillColor.cgColor
    }
    
    @objc func blackPin() {
        UIView.animate(withDuration: 0.25) {
            if self.pinView.layer.backgroundColor == self.maskColor.cgColor {
                self.pinLabel.text = ""
                self.pinView.layer.backgroundColor = self.fillColor.cgColor
                self.pinView.layer.borderColor = self.fillColor.cgColor
            }
        }
    }
    
    private func whitePin() {
        self.pinView.layer.backgroundColor = maskColor.cgColor
        self.pinView.layer.borderColor = maskColor.cgColor
    }
    
}
