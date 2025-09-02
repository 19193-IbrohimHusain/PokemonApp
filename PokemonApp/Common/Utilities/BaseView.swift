//
//  BaseView.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal func configView() {
        
    }
}
