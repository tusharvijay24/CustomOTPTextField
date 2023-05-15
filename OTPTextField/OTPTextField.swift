//
//  OTPTextField.swift
//  OTPTextField
//
//  Created by Apple on 15/05/23.
//

import UIKit

class OTPTextField: UIView {
    
    private var isConfigured = false
    private var digitLabels = [UILabel]() // Array to hold digit labels
    private var textField = UITextField()
    
    // Customizable properties
    @IBInspectable var textColor: UIColor = .black {
        didSet {
            textField.textColor = textColor
            for label in digitLabels {
                label.textColor = textColor
            }
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = .lightGray {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
    }
    
    @IBInspectable var boxColor: UIColor = .lightGray {
        didSet {
            for label in digitLabels {
                label.backgroundColor = boxColor
            }
        }
    }
    
    @IBInspectable var boxCornerRadius: CGFloat = 8 {
        didSet {
            for label in digitLabels {
                label.layer.cornerRadius = boxCornerRadius
            }
        }
    }
    
    @IBInspectable var boxSpacing: CGFloat = 8 {
        didSet {
            stackView.spacing = boxSpacing
        }
    }
    
    @IBInspectable var boxSize: CGSize = CGSize(width: 40, height: 40) {
        didSet {
            updateDigitLabelConstraints()
        }
    }
    
    private var stackView = UIStackView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    private func configure() {
        guard isConfigured == false else { return }
        
        configureTextField()
        
        // Create digit labels and add them to the stack view
        for _ in 1...6 { // Customize the range based on the desired number of digits
            let digitLabel = UILabel()
            digitLabel.translatesAutoresizingMaskIntoConstraints = false
            digitLabel.textAlignment = .center
            digitLabel.font = UIFont.systemFont(ofSize: 30)
            digitLabel.backgroundColor = boxColor
            digitLabel.textColor = textColor
            digitLabel.layer.cornerRadius = boxCornerRadius
            digitLabel.clipsToBounds = true
            digitLabels.append(digitLabel)
            stackView.addArrangedSubview(digitLabel)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = boxSpacing
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(textField)
        
        textField.frame = CGRect.zero // The textField will not be visible but will be able to become first responder
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        self.addGestureRecognizer(tapGesture)
        
        isConfigured = true
    }
    
    private func configureTextField() {
        textField.delegate = self
        textField.keyboardType = .numberPad // To show number pad for input
        textField.textColor = textColor
        textField.tintColor = .clear
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc
    private func textDidChange() {
        guard let text = textField.text, text.count <= digitLabels.count else { return }
        
        for i in 0 ..< digitLabels.count {
            let currentLabel = digitLabels[i]
            
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text?.removeAll()
            }
        }
    }
    
    private func updateDigitLabelConstraints() {
        for label in digitLabels {
            NSLayoutConstraint.deactivate(label.constraints) // Deactivate old constraints
            
            label.widthAnchor.constraint(equalToConstant: boxSize.width).isActive = true
            label.heightAnchor.constraint(equalToConstant: boxSize.height).isActive = true
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // If the user taps anywhere in this view, make the textField become the first responder
        if let result = super.hitTest(point, with: event) {
            textField.becomeFirstResponder()
            return result
        }
        return nil
    }
    
    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension OTPTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= digitLabels.count // 6 characters limit
    }
}
