//
//  FormTextfield.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import UIKit

final class FormTextField: UITextField {
    var padding: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            layoutIfNeeded()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupTextField() {
        setBorder(1, color: .systemGray4)
        font = .systemFont(ofSize: 14, weight: .regular)
        backgroundColor = .white
        setCornerRadius(radius: 12)
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboardType = .default
        spellCheckingType = .no
    }
}
